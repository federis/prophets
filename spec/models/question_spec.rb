require 'spec_helper'

describe Question do
  it "is automatically approved on save if created by a league admin" do
    admin = FactoryGirl.create(:user)
    league = FactoryGirl.create(:league_with_admin, :admin => admin)
    question = FactoryGirl.build(:question, :user => admin, :league => league, :approver => nil)
    
    question.save
    question.approver.should == admin
    question.approved_at.should_not be_nil
  end

  it "is not automatically approved on save if created by a non-admin" do
    user = FactoryGirl.create(:user)
    league = FactoryGirl.create(:league_with_member, :member => user)
    question = FactoryGirl.build(:question, :user => user, :league => league, :approver => nil)
    
    question.save
    question.approver.should be_nil
  end
end
