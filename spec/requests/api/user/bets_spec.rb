require 'spec_helper'

describe "As a normal user, Bets" do
  let(:user){ FactoryGirl.create(:user) }
  let(:league){ FactoryGirl.create(:league_with_member, :member => user) }
  let(:question){ FactoryGirl.create(:question, :user => user, :league => league, :approved_at => Time.now) }
  let(:answer){ FactoryGirl.create(:answer, :question => question, :user => user) }
  let(:membership){ user.membership_in_league(league) }
  let(:bet_attrs){ {:amount => 2} }
  let(:other_user_membership){ FactoryGirl.create(:membership, :league => league) }

  it "creates a bet in an approved question" do
    count = answer.bets.count
    before_prob = answer.current_probability
    
    post answer_bets_path(answer), :bet => bet_attrs,
                                   :auth_token => user.authentication_token,
                                   :format => "json"
    
    response.status.should == 201
    answer.bets.count.should == count+1
    
    json = decode_json(response.body)['bet']
    json['id'].should_not be_nil
    json['membership_id'].should == membership.id
    json['membership']['id'].should == membership.id
    json['answer_id'].should == answer.id
    json['amount'].should == bet_attrs[:amount]
    json['probability'].should == before_prob
    json['bonus'].should be_nil
    json['payout'].should be_nil
    json.keys.should include('payout', 'bonus')
  end

  it "gets a list of the user's bets in a league" do
    bet1 = FactoryGirl.create(:bet, :membership => membership, :answer => answer)
    bet2 = FactoryGirl.create(:bet, :membership => membership, :answer => answer)
    not_own_bet = FactoryGirl.create(:bet, :membership => other_user_membership, :answer => answer)

    get league_bets_path(league), :auth_token => user.authentication_token,
                                  :format => "json"

    response.status.should == 200
    json = decode_json(response.body) 
    question_ids = json.map{|l| l["bet"]["id"] }
    question_ids.should_not include(not_own_bet.id)
    question_ids.should include(bet1.id, bet2.id)
    
    json.first["bet"]["answer"].should_not be_nil
    json.first["bet"]["answer"]["question"].should_not be_nil
  end

  it "shows a bet" do
    bet = FactoryGirl.create(:bet, :membership => membership, :answer => answer)

    get bet_path(bet), :auth_token => user.authentication_token,
                       :format => "json"

    response.status.should == 200
    json = decode_json(response.body)           
    json["bet"]["amount"].should == bet.amount
    json["bet"]["probability"].should == bet.probability
    json["bet"]["answer"].should_not be_nil
    json["bet"]["answer"]["question"].should_not be_nil
  end

end
