require 'spec_helper'

describe "As a normal user, Bets" do
  let(:admin){ FactoryGirl.create(:user, :name => "Admin") }
  let(:league){ FactoryGirl.create(:league_with_admin, :admin => admin) }
  let(:other_user_membership){ FactoryGirl.create(:membership, :league => league) }
  let(:question){ FactoryGirl.create(:question, :user => admin, :league => league, :approved_at => Time.now) }
  let(:answer){ FactoryGirl.create(:answer, :question => question) }

  it "invalidates a bet but doesn't delete it" do
    bet = FactoryGirl.create(:bet, :membership => other_user_membership, :answer => answer)
    count = answer.bets.count

    delete answer_bet_path(answer, bet), :auth_token => admin.authentication_token,
                                         :format => "json"
    
    response.status.should == 204
    answer.bets.count.should == count
    bet.reload.should be_invalidated
  end

end
