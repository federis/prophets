require 'spec_helper'

describe "As a normal user, Questions" do
  let(:user){ FactoryGirl.create(:user) }
  let(:league){ FactoryGirl.create(:league_with_member, :member => user) }
  let(:question){ FactoryGirl.create(:question, :user => user, :league => league, :approved_at => Time.now) }
  let(:answer){ FactoryGirl.create(:answer, :question => question, :user => user) }
  let(:membership){ user.membership_in_league(league) }
  let(:bet){ FactoryGirl.create(:bet, :answer => answer, :membership => membership) }

  it "lists the currently running questions in a league" do
    a1 = FactoryGirl.create(:activity, :bet_created, :league => league, :feedable => bet)
    a2 = FactoryGirl.create(:activity, :bet_payout, :league => league, :feedable => bet)
    a3 = FactoryGirl.create(:activity, :question_published, :league => league, :feedable => question)
    a4 = FactoryGirl.create(:activity, :question_published)
    
    get league_activities_path(league), :auth_token => user.authentication_token,
                                        :format => "json"

    response.status.should == 200
    json = decode_json(response.body) 
    activity_ids = json.map{|l| l["activity"]["id"] }
    activity_ids.should include(a1.id)
    activity_ids.should include(a2.id)
    activity_ids.should include(a3.id)
    activity_ids.should_not include(a4.id)
    
    activity_json = json.first["activity"]
    activity_json.should have_key("content")
    activity_json.should have_key("feedable_type")
    activity_json.should have_key("feedable_id")
    activity_json.should have_key("comments_count")
  end

end
