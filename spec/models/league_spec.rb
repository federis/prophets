require 'spec_helper'

describe League do
  it "makes the league creator an admin after creation" do
    u = FactoryGirl.create(:user)
    l = League.new(:name => "the league")
    l.user = u
    l.save

    l.admins.should include(u)
  end
end
