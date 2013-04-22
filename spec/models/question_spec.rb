require 'spec_helper'

describe Question do

  it "#approve! raises an exception and doesn't approve question if approving_user isn't an admin" do
    user = FactoryGirl.create(:user)
    league = FactoryGirl.create(:league)
    question = FactoryGirl.create(:question, :unapproved, :league => league)
    
    expect{ question.approve!(user) }.to raise_error(CanCan::AccessDenied)

    question.reload.approver.should be_nil
    question.approved_at.should be_nil
  end

  it "#approve! approves the question, saves it, generates an activity entry, and queues a job to send push notifications" do
    admin = FactoryGirl.create(:user)
    league = FactoryGirl.create(:league_with_admin, :admin => admin)
    question = FactoryGirl.create(:question, :with_answers, :user => admin, :league => league, :approver => nil)
    
    Resque.should_receive(:enqueue).with(SendNotificationsForNewQuestionJob, question.id)
    
    activity_count = Activity.count
    question.approve!(admin)

    Activity.count.should == activity_count + 1
    activity = Activity.last
    activity.feedable.should == question
    activity.activity_type.should == Activity::TYPES[:question_published]

    question.approver.should == admin
    question.approved_at.should_not be_nil

    question.reload
    question.approved_at.should_not be_nil
  end

  it "won't approve a question where the answer probabilities don't sum to 100" do
    question = FactoryGirl.create(:question, :with_answers, :answers_count => 3, :approved_at => nil, :approver => nil)
    answer = question.answers.first
    answer.initial_probability = 0.5
    answer.save
    
    question.approve!(question.league.user)
    
    question.errors[:answers].should include(I18n.t('activerecord.errors.models.question.attributes.answers.invalid_initial_probabilities_sum'))
    question.reload.approved_at.should be_blank
  end

  it "#total_pool gives the sum of the bets made in the question plus the question's initial pool" do
    question = FactoryGirl.create(:question, :with_answers, :answers_count => 3)
    question.answers.each{|a| a.bet_total = 1000; a.save }

    question.total_pool.should == 3000 + question.initial_pool
  end

  it "#update_answer_probabilities! recalculates and saves the probabilities for the question's answers" do
    question = FactoryGirl.create(:question)
    init_probs = [0.5, 0.3, 0.2]
    for i in 1..3
      eval <<-RUBY
        @answer#{i} = question.answers.build(:content => 'answer #{i}')
        @answer#{i}.user = question.user
        @answer#{i}.initial_probability = init_probs[i-1]
        @answer#{i}.save
      RUBY
    end

    @answer1.bet_total = 1000

    question.update_answer_probabilities!

    @answer1.current_probability.should == 0.54545
    @answer2.current_probability.should == 0.27273
    @answer3.current_probability.should == 0.18182
  end

  it "is invalid when close of betting is in the past" do
    question = FactoryGirl.build(:question)
    question.betting_closes_at = 1.day.ago

    question.should_not be_valid
    question.errors[:betting_closes_at].should include(I18n.t('activerecord.errors.models.question.attributes.betting_closes_at.cant_be_in_past'))
  end

  it "is open for betting after approval and before close of betting" do
    question = FactoryGirl.build(:question, :betting_closes_at => 1.day.ago, :approved_at => nil)
    question.should_not be_open_for_betting

    question.betting_closes_at = 1.week.from_now
    question.should_not be_open_for_betting

    question.approved_at = 1.day.ago
    question.betting_closes_at = 1.day.ago
    question.should_not be_open_for_betting

    question.betting_closes_at = 1.week.from_now
    question.should be_open_for_betting    
  end

end
