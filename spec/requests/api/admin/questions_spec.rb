require 'spec_helper'

describe "As an admin, Questions" do
  let(:admin){ FactoryGirl.create(:user) }
  let(:question_attrs){ FactoryGirl.attributes_for(:question) }
  let(:league){ FactoryGirl.create(:league_with_admin, :admin => admin) }

  it "creates a question" do
    count = league.questions.count
    
    post league_questions_path(league), :question => question_attrs,
                                       :auth_token => admin.authentication_token,
                                       :format => "json"

    response.status.should == 201
    league.questions.count.should == count+1
    
    json = decode_json(response.body)['question']
    json['id'].should_not be_nil
    json['content'].should == question_attrs[:content]
    json['user_id'].should == admin.id
    json['league_id'].should == league.id
    json['desc'].should == question_attrs[:desc]
    json['approver_id'].should == admin.id
    json['approved_at'].should_not be_nil
  end

end
