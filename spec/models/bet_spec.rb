require 'spec_helper'

describe Bet do
  it "can't make a bet with an amount larger than the league's max bet" do
    answer = FactoryGirl.create(:answer)
    bet = FactoryGirl.build(:bet, :answer => answer, :amount => answer.question.league.max_bet+1)
    
    bet.should_not be_valid
    bet.errors_on(:amount).should include("must be less than or equal to #{answer.question.league.max_bet}")
  end  

  it "increments the answer's bet total by the bet amount after creation" do
    answer = FactoryGirl.create(:answer)
    bet = FactoryGirl.build(:bet, :answer => answer)
    before_total = answer.bet_total
    bet.save
    answer.reload

    answer.bet_total.should == before_total + bet.amount
  end

  it "decrements the answer's bet total by the bet amount after destruction" do
    answer = FactoryGirl.create(:answer)
    bet = FactoryGirl.create(:bet, :answer => answer)
    before_total = answer.bet_total
    bet.destroy
    answer.reload

    answer.bet_total.should == before_total - bet.amount
  end

  it "#invalidate! decrements the answer's bet total by the bet amount and sets the invalidated_at timestamp and saves the bet & answer" do
    bet = FactoryGirl.create(:bet)
    before_total = bet.answer.bet_total
    bet.should_not be_invalidated

    bet.invalidate!

    bet.reload
    bet.should be_invalidated
    bet.invalidated_at.should_not be_nil
    bet.answer.reload.bet_total.should == before_total - bet.amount
  end

  it "updates probabilities for all answers in the question after creation" do
    question = FactoryGirl.create(:question_with_answers)
    answer = question.answers.first
    answer_prob = answer.current_probability
    
    bet = question.user.bets.build(:answer_id => answer.id, :amount => 1000)
    bet.answer.question.should_receive(:update_answer_probabilities!)
    bet.save
  end

end
