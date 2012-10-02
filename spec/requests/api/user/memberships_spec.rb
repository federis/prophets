require 'spec_helper'

describe "As a normal user, Memberships" do
  let(:user){ FactoryGirl.create(:user) }
  let(:auth_token){ user.authentication_token }
  let(:membership_attrs){ FactoryGirl.attributes_for(:membership).except(:role) }

  it "lists the user's memberships" do
    league_where_not_member = FactoryGirl.create(:league, :priv => false)
    public_league = FactoryGirl.create(:league_with_member, :priv => false, :member => user)
    league_where_member = FactoryGirl.create(:league_with_member, :priv => true, :member => user)
    league_where_admin = FactoryGirl.create(:league_with_admin, :priv => true, :admin => user)

    memberships = []
    [public_league, league_where_admin, league_where_member].each do |l|
      memberships << user.membership_in_league(l).id
    end

    get memberships_path, :auth_token => auth_token, :format => "json"

    response.status.should == 200

    json = decode_json(response.body)
    
    membership_ids = json.map{|m| m["membership"]["id"] }
    membership_ids.should include(*memberships)

    json.first["membership"]["league"]["id"].should == public_league.id
  end

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
    json['balance'].should == public_league.initial_balance
  end

  it "deletes a league membership" do
    league_where_member = FactoryGirl.create(:league_with_member, :member => user)

    count = user.memberships.count

    delete league_membership_path(league_where_member, user.membership_in_league(league_where_member)),
           :auth_token => auth_token,
           :format => "json"
    
    response.status.should == 204
  end
end
