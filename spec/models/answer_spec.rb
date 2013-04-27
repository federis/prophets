require 'spec_helper'

describe Answer do
  let(:league){ FactoryGirl.create(:league) }
  let(:question){ FactoryGirl.create(:question, league: league) }
  let(:answer_with_bets){ FactoryGirl.create(:answer_with_bets, :bet_user => user, :question => question) }
  let(:judged_answer) do
      answer_with_bets.judge!(true, admin)
      answer_with_bets
    end
  
  let(:admin) do
    admin = FactoryGirl.create(:user)
    lm = Membership.new
    lm.user = admin
    lm.role = Membership::ROLES[:admin]
    league.memberships << lm
    admin
  end
  let(:user) do
    user = FactoryGirl.create(:user)
    user.leagues << league
    user
  end
  let(:membership){ user.membership_in_league(question.league) }

  it "sets current prob to initial prob on creation" do
    a = FactoryGirl.build(:answer)
    a.current_probability.should be_nil
    a.save
    a.current_probability.should eq(a.initial_probability)
  end

  it "#total_pool_share gives answer's total bet value plus the answer's portion of the initial pool" do
    question = FactoryGirl.create(:question, :with_answers, :answers_count => 3)
    a = question.answers.first
    a.bet_total = 1000
    a.save

    a.total_pool_share.should == 1000 + question.initial_pool * a.initial_probability
  end

  it "#pay_bettors! pays the user for each bet made in the answer" do
    answer_with_bets.bets.each do |bet|
      bet.should_receive(:pay_bettor!)
    end

    answer_with_bets.pay_bettors!
  end

  it "#zero_bet_payouts! zeroes the payout on each bet made in the answer" do
    answer_with_bets.bets.each do |bet|
      bet.should_receive(:zero_payout!)
    end

    answer_with_bets.zero_bet_payouts!
  end

  it "#process_bets_for_judgement pays bettors for a correct answer" do
    answer_with_bets.should_receive(:pay_bettors!)
    answer_with_bets.process_bets_for_judgement(true)
  end

  it "#process_bets_for_judged_answer zeros the payouts for bets in an incorrect answer" do
    answer_with_bets.should_receive(:zero_bet_payouts!)
    answer_with_bets.process_bets_for_judgement(false)
  end

  it "is open for betting if the question is open for betting and the answer has not been judged" do
    answer = FactoryGirl.build(:answer, :judged_at => 1.day.ago)
    answer.question.stub(:open_for_betting?).and_return(false)
    answer.should_not be_open_for_betting

    answer.judged_at = nil
    answer.should_not be_open_for_betting

    answer.judged_at = 1.day.ago
    answer.question.stub(:open_for_betting?).and_return(true)
    answer.should_not be_open_for_betting

    answer.judged_at = nil
    answer.should be_open_for_betting
  end

  it "updates the current probabilities for all answers in the question if the bet total changed" do
    q = FactoryGirl.create(:question, :with_answers)
    a1 = q.answers[0]
    a2 = q.answers[1]
    a3 = q.answers[2]

    a1.current_probability.to_s.should == "0.33333"
    a2.current_probability.to_s.should == "0.33333"
    a3.current_probability.to_s.should == "0.33333"
    
    a1.bet_total += 500
    a1.save

    a1.reload.current_probability.to_s.should == "0.36508"
    a2.reload.current_probability.to_s.should == "0.31746"
    a3.reload.current_probability.to_s.should == "0.31746"
  end

  describe "#judge!" do
    let(:question){ FactoryGirl.create(:question, :with_answers, league: league) }
    let(:answer){ question.answers.first }

    it "sets the judged info and processes bets" do
      Answer.stub(:find).and_return(answer)
      
      answer.should_receive(:process_bets_for_judgement).with(false, nil).once

      answer.judge!(false, admin)

      answer.reload
      answer.correct.should == false 
      answer.judged_at.should_not be_nil
      answer.judge.should == admin
    end

    it "enqueues the ProcessBetsForJudgedAnswerJob" do
      Resque.should_receive(:enqueue).at_least(1).times.with(ProcessBetsForJudgedAnswerJob, answer.id, false, nil)
      answer.judge!(false, admin)
    end

    it "calls judge! for other answers in the same question when it is the correct answer" do
      answer.question.answers.each do |a|
        a.should_receive(:judge!).with(false, admin, nil) unless a == answer
      end

      answer.judge!(true, admin)
    end

    it "doesn't call judge! for other answers in the same question when it is the incorrect answer" do
      answer.question.answers.each do |a|
        a.should_not_receive(:judge!) unless a == answer
      end
      answer.judge!(false, admin)
    end

    it "doesn't call judge! for other answers that have already been judged" do
      judged_answer = double("Answer")
      judged_answer.stub(:judged?).and_return(true)
      answer.question.stub(:answers).and_return([judged_answer])
      
      judged_answer.should_not_receive(:judge!)
      answer.judge!(true, admin)
    end

    it "invalidates bets made after the known_at date" do
      bet1 = FactoryGirl.create(:bet, :answer => answer, :membership => membership, :created_at => 1.week.ago)
      bet2 = FactoryGirl.create(:bet, :answer => answer, :membership => membership)
      
      answer.judge!(true, admin, 2.days.ago)

      bet1.reload.should_not be_invalidated
      bet1.should be_judged

      bet2.reload.should be_invalidated
      bet2.should_not be_judged
    end

    it "sets the completed_at date for the question if all the answers have been judged" do
      question.answers.each do |a|
        Answer.update_all({judged_at: Time.now, judge_id: admin.id}, {id: a.id}) unless a == answer
      end

      answer.judge!(true, admin)

      answer.reload
      answer.question.completed_at.should_not be_blank
    end
  end

  describe "undoing judgement" do
    let(:question){ FactoryGirl.create(:question, :with_answers, league: league) }

    before(:each) do
      judged_answer #trigger creation & judgement
    end

    it "erases the judged info and undoes bet payouts" do
      Answer.stub(:find).and_return(judged_answer)
      
      judged_answer.should_receive(:undo_bet_judgements!).once

      judged_answer.undo_judgement!

      judged_answer.reload
      judged_answer.correct.should be_nil 
      judged_answer.judged_at.should be_nil
      judged_answer.judge.should be_nil
      judged_answer.correctness_known_at.should be_nil
    end

    it "enqueues the ProcessBetsForJudgedAnswerJob" do
      Resque.should_receive(:enqueue).at_least(1).times.with(UndoBetPayoutsForAnswerJob, judged_answer.id)
      judged_answer.undo_judgement!
    end
  end

  it "undo_bet_judgements calls bet#undo_payout for each bet" do
    judged_answer.bets.each do |bet|
      bet.should_receive(:undo_judgement!)
    end

    judged_answer.undo_bet_judgements!
  end

end
