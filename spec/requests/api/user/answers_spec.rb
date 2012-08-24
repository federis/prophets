require 'spec_helper'

describe "As a normal user, Questions" do
  let(:user){ FactoryGirl.create(:user) }
  let(:league){ FactoryGirl.create(:league_with_member, :member => user) }
  let(:question){ FactoryGirl.create(:question, :user => user, :league => league) }
  let(:answer_attrs){ FactoryGirl.attributes_for(:answer, :user => user, :question => question) }

  it "creates an answer" do
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
  end

  it "updates an answer" do
    answer = FactoryGirl.create(:answer, :question => question)

    put question_answer_path(question, answer), :answer => { :content => "updated content" },
                                                :auth_token => user.authentication_token,
                                                :format => "json"

    response.status.should == 204

    answer.reload
    answer.content.should == "updated content"
  end

end
