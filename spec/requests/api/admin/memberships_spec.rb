require 'spec_helper'

describe "As an admin, Memberships" do
  let(:admin){ FactoryGirl.create(:user) }
  let(:other_user){ FactoryGirl.create(:user) }
  let(:other_membership_attrs){ FactoryGirl.attributes_for(:membership, :user => other_user).except(:role).merge(:user_id => other_user.id) }
  let(:private_league){ FactoryGirl.create(:league_with_admin, :private, :admin => admin) }

  it "creates a league membership for another user in a private league" do
    count = other_user.memberships.count
    
    post league_memberships_path(private_league), :membership => other_membership_attrs, 
                                                  :league_password => "abc123",
                                                  :auth_token => admin.authentication_token,
                                                  :format => "json"
        
    response.status.should == 201
    other_user.memberships.count.should == count+1

    json = decode_json(response.body)['membership']
    json['id'].should_not be_nil
    json['league_id'].should == private_league.id
    json['user_id'].should == other_user.id
    json['role'].should == Membership::ROLES[:member]
  end

  it "deletes a league membership for another user in a private league" do
    private_league.users << other_user

    count = other_user.memberships.count

    delete league_membership_path(private_league, other_user.membership_in_league(private_league)),
           :auth_token => admin.authentication_token,
           :format => "json"
    
    response.status.should == 204
    other_user.memberships.count.should == count - 1
  end
end
