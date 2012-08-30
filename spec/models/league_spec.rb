require 'spec_helper'

describe League do
  it "makes the league creator an admin after creation" do
    u = FactoryGirl.create(:user)
    l = FactoryGirl.build(:league, :user => u)
    l.save
    
    l.admins.should include(u)
  end
end
