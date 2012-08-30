require 'spec_helper'

describe "As a normal user, Bets" do
  let(:user){ FactoryGirl.create(:user) }
  let(:league){ FactoryGirl.create(:league_with_member, :member => user) }
  let(:question){ FactoryGirl.create(:question, :user => user, :league => league, :approved_at => Time.now) }
  let(:answer){ FactoryGirl.create(:answer, :question => question, :user => user) }
  let(:bet_attrs){ FactoryGirl.attributes_for(:bet, :user => user, :answer => answer).except(:probability) }

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
    json['user_id'].should == user.id
    json['answer_id'].should == answer.id
    json['amount'].should == bet_attrs[:amount]
    json['probability'].should == before_prob
    json['bonus'].should be_nil
  end

end
