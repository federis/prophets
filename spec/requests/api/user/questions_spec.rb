require 'spec_helper'

describe "As a normal user, Questions" do
  let(:user){ FactoryGirl.create(:user) }
  let(:league){ FactoryGirl.create(:league_with_member, :member => user) }

  it "creates a question but doesn't approve it" do
    question_attrs = FactoryGirl.attributes_for(:question).except(:approved_at, :approver_id)
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
    json['comments_count'].should == 0
    json['bets_count'].should == 0
    json['betting_closes_at'].should == question_attrs[:betting_closes_at].iso8601
  end

  it "doesn't update a question or add an answer to approved questions" do

    question = FactoryGirl.create(:question, :league => league, :user => user)
    answers_attrs = [{:content => "answer content", :initial_probability => 0.5}]
    
    expect{
        put league_question_path(league, question), :question => { :content => "updated content", :answers_attributes => answers_attrs },
                                                    :auth_token => user.authentication_token,
                                                    :format => "json"
    }.to raise_error(CanCan::AccessDenied)

  end

  it "updates a question and adds an answer to it" do

    question = FactoryGirl.create(:question, :unapproved, :league => league, :user => user)
    answers_attrs = [{:content => "answer content", :initial_probability => 0.5}]


    answers_count = question.answers.count

    put league_question_path(league, question), :question => { :content => "updated content", :answers_attributes => answers_attrs },
                                                :auth_token => user.authentication_token,
                                                :format => "json"

    response.status.should == 200

    question.answers.count.should == answers_count + 1

    question.reload
    question.content.should == "updated content"
    
    json = decode_json(response.body)
    json['question'].should_not be_nil
    json['question']['answers'].should_not be_nil    
  end

  it "updates a question and updates an answer" do

    question = FactoryGirl.create(:question, :unapproved, :with_answers, :league => league, :user => user, :answers_count => 1)
    answer = question.answers.first
    answers_attrs = [{:content => "updated answer content", :id => answer.id}]

    put league_question_path(league, question), :question => { :answers_attributes => answers_attrs },
                                                :auth_token => user.authentication_token,
                                                :format => "json"

    response.status.should == 200

    answer.reload.content.should == "updated answer content"
  
  end

  it "updates a question and removes an answer" do

    question = FactoryGirl.create(:question, :unapproved, :with_answers, :league => league, :user => user, :answers_count => 2)
    answer = question.answers.first
    answers_attrs = [{:content => "updated answer content", :id => answer.id}]

    answers_count = question.answers.count

    put league_question_path(league, question), :question => { :answers_attributes => answers_attrs },
                                                :auth_token => user.authentication_token,
                                                :format => "json"

    response.status.should == 200

    question.answers.count.should == answers_count - 1
  end

  it "shows an approved question" do
    question = FactoryGirl.create(:question, :league => league, :approved_at => Time.now)
    answer = FactoryGirl.create(:answer, :question => question)

    get league_question_path(league, question), :auth_token => user.authentication_token,
                                                :format => "json"

    response.status.should == 200

    json = decode_json(response.body)['question']
    json['id'].should_not be_nil
    json['content'].should == question.content
    json['user_id'].should == question.user_id
    json['league_id'].should == league.id
    json['desc'].should == question.desc
    json['approver_id'].should == question.approver_id
    json['approved_at'].should == question.approved_at.iso8601
    
    answer_json = json['answers'].first
    answer_json['id'].should == answer.id
    answer_json['content'].should == answer.content
    answer_json['question_id'].should == question.id
    answer_json['user_id'].should == answer.user_id
    answer_json['initial_probability'].should == answer.initial_probability
    answer_json['current_probability'].should == answer.initial_probability
    answer_json['bet_total'].should == 0
    answer_json['correct'].should be_nil
    answer_json['judged_at'].should be_nil
    answer_json['correctness_known_at'].should be_nil
    answer_json.keys.should include('correct', 'judged_at', 'judge_id', 'correctness_known_at')
  end

  it "lists the approved questions in a league" do
    q1 = FactoryGirl.create(:question, :with_answers, :league => league, :approved_at => Time.now)
    q2 = FactoryGirl.create(:question, :league => league, :approved_at => Time.now)
    q3 = FactoryGirl.create(:question, :unapproved, :league => league)
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

    json.first["question"]["answers"].should_not be_nil
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
