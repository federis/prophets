require 'spec_helper'

describe "As a normal user, Answers" do
  let(:user){ FactoryGirl.create(:user) }
  let(:league){ FactoryGirl.create(:league_with_member, :member => user) }
  let(:question){ FactoryGirl.create(:question, :user => user, :league => league, :approved_at => nil) }
  let(:answer){ FactoryGirl.create(:answer, :question => question, :user => user) }
  let(:answer_attrs){ FactoryGirl.attributes_for(:answer, :user => user, :question => question) }

  it "creates an answer in an unapproved question" do
    count = question.answers.count
    
    post question_answers_path(question), :answer => answer_attrs,
                                          :auth_token => user.authentication_token,
                                          :format => "json"

    response.status.should == 201
    question.answers.count.should == count+1
    
    json = decode_json(response.body)['answer']
    json['id'].should_not be_nil
    json['content'].should == answer_attrs[:content]
    json['user_id'].should == user.id
    json['question_id'].should == question.id
    json['initial_probability'].should == answer_attrs[:initial_probability]
    json['current_probability'].should == answer_attrs[:initial_probability]
    json['bet_total'].should == 0
    json['correct'].should be_nil
    json['judged_at'].should be_nil
    json['judge_id'].should be_nil
    json['correctness_known_at'].should be_nil
    json.keys.should include('correct', 'judged_at', 'judge_id', 'correctness_known_at')
  end

  it "updates an answer in an unapproved question" do
    put question_answer_path(question, answer), :answer => { :content => "updated content" },
                                                :auth_token => user.authentication_token,
                                                :format => "json"

    response.status.should == 204

    answer.reload
    answer.content.should == "updated content"
  end

  it "deletes an answer in an unapproved question" do
    answer #trigger answer creation
    count = question.answers.count

    delete question_answer_path(question, answer),
           :auth_token => user.authentication_token,
           :format => "json"
    
    response.status.should == 204
    question.answers.count.should == count - 1
  end

end
