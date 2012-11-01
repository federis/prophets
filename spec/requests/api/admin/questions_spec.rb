require 'spec_helper'

describe "As an admin, Questions" do
  let(:admin){ FactoryGirl.create(:user, :name => "Admin") }
  let(:league){ FactoryGirl.create(:league_with_admin, :admin => admin) }

  it "creates a question" do
    question_attrs = FactoryGirl.attributes_for(:question).except(:approved_at, :approver_id)
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
    json['approver_id'].should be_nil
    json['approved_at'].should be_nil
  end

  it "updates a question" do
    question = FactoryGirl.create(:question, :with_answers, :league => league)

    put league_question_path(league, question), :question => { :content => "updated content" },
                                                :auth_token => admin.authentication_token,
                                                :format => "json"

    response.status.should == 204

    question.reload
    question.content.should == "updated content"
  end

  it "approves a question" do
    question = FactoryGirl.create(:question, :with_answers, :league => league)

    put approve_league_question_path(league, question), :auth_token => admin.authentication_token,
                                                        :format => "json"

    response.status.should == 204

    question.reload
    question.approver.should == admin
    question.approved_at.should_not be_nil
  end

  it "lists the unapproved questions in a league" do
    q1 = FactoryGirl.create(:question, :league => league, :approved_at => Time.now)
    q2 = FactoryGirl.create(:question, :unapproved, :league => league)

    get league_questions_path(league), :auth_token => admin.authentication_token,
                                       :type => "unapproved",
                                       :format => "json"

    response.status.should == 200
    json = decode_json(response.body) 
    question_ids = json.map{|l| l["question"]["id"] }
    question_ids.should_not include(q1.id)
    question_ids.should include(q2.id)
  end

  it "lists all questions in a league" do
    q1 = FactoryGirl.create(:question, :league => league, :approved_at => Time.now)
    q2 = FactoryGirl.create(:question, :league => league)

    get league_questions_path(league), :auth_token => admin.authentication_token,
                                       :type => "all",
                                       :format => "json"

    response.status.should == 200
    json = decode_json(response.body) 
    question_ids = json.map{|l| l["question"]["id"] }
    question_ids.should include(q1.id)
    question_ids.should include(q2.id)
  end

  it "deletes an already approved question" do
    q = FactoryGirl.create(:question, :league => league, :approved_at => Time.now)
    count = league.questions.count

    delete league_question_path(league, q),
           :auth_token => admin.authentication_token,
           :format => "json"
    
    response.status.should == 204
    league.questions.count.should == count - 1
  end

end
