require 'spec_helper'

describe Answer do
  let(:question){ FactoryGirl.create(:question) }
  let(:answer_with_bets){ FactoryGirl.create(:answer_with_bets, :bet_user => user, :question => question) }
  let(:user) do
    user = FactoryGirl.create(:user)
    user.leagues << question.league
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

  it "#process_bets_for_judged_answer pays bettors for a correct answer" do
    Answer.stub(:find).and_return(answer_with_bets)
    answer_with_bets.should_receive(:pay_bettors!)
    Answer.process_bets_for_judged_answer(answer_with_bets.id, true)
  end

  it "#process_bets_for_judged_answer zeros the payouts for bets in an incorrect answer" do
    Answer.stub(:find).and_return(answer_with_bets)
    answer_with_bets.should_receive(:zero_bet_payouts!)
    Answer.process_bets_for_judged_answer(answer_with_bets.id, false)
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

  describe "#judge!" do
    let(:question){ FactoryGirl.create(:question, :with_answers) }
    before(:each) do
      @answer = question.answers.first
      membership.role = Membership::ROLES[:admin]
      membership.save
    end

    it "sets the judged info and processes bets" do
      dj = mock("DelayProxy")
      Answer.should_receive(:delay).any_number_of_times.and_return(dj)
      dj.should_receive(:process_bets_for_judged_answer).with(@answer.id, true, nil).once
      dj.should_receive(:process_bets_for_judged_answer).any_number_of_times

      @answer.judge!(true, user)

      @answer.reload.should be_correct
      @answer.judged_at.should_not be_nil
      @answer.judge.should == user
    end

    it "calls judge! for other answers in the same question when it is the correct answer" do
      dj = mock("DelayProxy")
      Answer.should_receive(:delay).any_number_of_times.and_return(dj)
      dj.should_receive(:process_bets_for_judged_answer).with(@answer.id, true, nil).once

      @answer.question.answers.each do |a|
        a.should_receive(:judge!).with(false, user, nil) unless a == @answer
      end

      @answer.judge!(true, user)
    end

    it "doesn't call judge! for other answers in the same question when it is the incorrect answer" do
      dj = mock("DelayProxy")
      Answer.should_receive(:delay).and_return(dj)
      dj.should_receive(:process_bets_for_judged_answer).with(@answer.id, false, nil).once

      @answer.judge!(false, user)
    end

    it "invalidates bets made after the known_at date" do
      bet1 = FactoryGirl.create(:bet, :answer => @answer, :membership => membership, :created_at => 1.week.ago)
      bet2 = FactoryGirl.create(:bet, :answer => @answer, :membership => membership)
      
      @answer.judge!(true, user, 2.days.ago)

      bet1.reload.should_not be_invalidated
      bet1.should be_judged

      bet2.reload.should be_invalidated
      bet2.should_not be_judged
    end

    it "sets the completed_at date for the question if all the answers have been judged" do
      question.answers.each do |a|
        Answer.update_all({judged_at: Time.now, judge_id: user.id}, {id: a.id}) unless a == @answer
      end

      @answer.judge!(true, user)

      @answer.reload
      @answer.question.completed_at.should_not be_blank
    end
  end

end
