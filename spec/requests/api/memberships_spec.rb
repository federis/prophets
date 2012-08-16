require 'spec_helper'

describe "Memberships" do
  let(:user){ FactoryGirl.create(:user) }
  let(:auth_token){ user.authentication_token }
  let(:membership_attrs){ FactoryGirl.attributes_for(:membership).except(:role) }

  it "creates a league membership" do
    public_league = FactoryGirl.create(:league, :priv => false)
    
    count = user.memberships.count

    post league_memberships_path(public_league), :membership => membership_attrs, 
                                                 :auth_token => auth_token,
                                                 :format => "json"
    
    response.status.should == 201
    user.memberships.count.should == count+1
    
    json = decode_json(response.body)['membership']
    json['id'].should_not be_nil
    json['league_id'].should == public_league.id
    json['user_id'].should == user.id
    json['role'].should == Membership::ROLES[:member]
  end
end
