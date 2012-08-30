require 'spec_helper'

describe Bet do
  it "can't make a bet with an amount larger than the league's max bet" do
    answer = FactoryGirl.create(:answer)
    bet = FactoryGirl.build(:bet, :answer => answer, :amount => answer.question.league.max_bet+1)
    
    bet.should_not be_valid
    bet.errors_on(:amount).should include("must be less than or equal to #{answer.question.league.max_bet}")
  end  
end
