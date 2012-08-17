require 'spec_helper'

describe "As a normal user, Questions" do
  let(:user){ FactoryGirl.create(:user) }
  let(:question_attrs){ FactoryGirl.attributes_for(:question) }
  let(:league){ FactoryGirl.create(:league_with_member, :member => user) }

  it "creates a question but doesn't approve it" do
    count = league.questions.count
    approved_count = league.questions.approved.count
    
    post league_questions_path(league), :question => question_attrs,
                                        :auth_token => user.authentication_token,
                                        :format => "json"

    response.status.should == 201
    league.questions.count.should == count+1
    league.questions.approved.count.should == approved_count
    
    json = decode_json(response.body)['question']
    json['id'].should_not be_nil
    json['content'].should == question_attrs[:content]
    json['user_id'].should == user.id
    json['league_id'].should == league.id
    json['desc'].should == question_attrs[:desc]
    json['approver_id'].should be_nil
    json['approved_at'].should be_nil
  end

end
