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

  it "lists the approved questions in a league" do
    q1 = FactoryGirl.create(:question, :league => league, :approved_at => Time.now)
    q2 = FactoryGirl.create(:question, :league => league, :approved_at => Time.now)
    q3 = FactoryGirl.create(:question, :league => league)
    q4 = FactoryGirl.create(:question, :approved_at => Time.now)

    get league_questions_path(league), :auth_token => user.authentication_token,
                                       :format => "json"

    response.status.should == 200
    json = decode_json(response.body) 
    question_ids = json.map{|l| l["question"]["id"] }
    question_ids.should include(q1.id)
    question_ids.should include(q2.id)
    question_ids.should_not include(q3.id)
    question_ids.should_not include(q4.id)
  end

  it "deletes an unapproved question" do
    q = FactoryGirl.create(:question, :league => league, :user => user, :approved_at => nil, :approver => nil)
    count = league.questions.count

    delete league_question_path(league, q),
           :auth_token => user.authentication_token,
           :format => "json"
    
    response.status.should == 204
    league.questions.count.should == count - 1
  end

end
