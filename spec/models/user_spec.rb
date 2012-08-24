require 'spec_helper'

describe User do
  it "#is_admin_of_league? returns the correct bool value" do
    u = FactoryGirl.create(:user)
    l = FactoryGirl.create(:league)
    u.is_admin_of_league?(l).should be_false

    m = l.memberships.build
    m.user = u
    m.role = Membership::ROLES[:admin]
    m.save
    
    u.is_admin_of_league?(l).should be_true
  end

  it "#is_member_of_league? returns the correct bool value" do
    u = FactoryGirl.create(:user)
    l = FactoryGirl.create(:league)
    u.is_member_of_league?(l).should be_false

    l.users << u

    u.is_member_of_league?(l).should be_true
  end
end
