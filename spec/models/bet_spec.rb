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

  it "updates probabilities for all answers in the question after creation" do
    question = FactoryGirl.create(:question_with_answers)
    answer = question.answers.first
    answer_prob = answer.current_probability
    
    bet = question.user.bets.build(:answer_id => answer.id, :amount => 1000)
    bet.answer.question.should_receive(:update_answer_probabilities!)
    bet.save
  end
end
