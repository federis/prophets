require 'spec_helper'

describe Membership do
  let(:answer){ FactoryGirl.create(:answer) }
  let(:user) do
    user = FactoryGirl.create(:user)
    user.leagues << answer.question.league
    user
  end
  let(:membership){ user.membership_in_league(answer.question.league) }
  
  it "#outstanding_bets_value gives the sum of the paid amount of outstanding bets in the membership's league" do
    FactoryGirl.create(:bet, :answer => answer, :user => user, :amount => 2)
    FactoryGirl.create(:bet, :answer => answer, :user => user, :amount => 5)
    FactoryGirl.create(:bet, :answer => answer, :user => user, :amount => 10)
    other_league_answer = FactoryGirl.create(:answer)
    other_league_answer.question.league.users << user
    FactoryGirl.create(:bet, :answer => other_league_answer, :user => user, :amount => 6)

    membership.outstanding_bets_value.should == 17
  end

end
