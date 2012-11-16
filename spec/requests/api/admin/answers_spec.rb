require 'spec_helper'

describe "As an admin, Answers" do
  let(:admin){ FactoryGirl.create(:user, :name => "Admin") }
  let(:league){ FactoryGirl.create(:league_with_admin, :admin => admin) }
  let(:question){ FactoryGirl.create(:question, :user => admin, :league => league, :approved_at => Time.now) }
  let(:answer){ FactoryGirl.create(:answer, :question => question) }
  let(:answer_attrs){ FactoryGirl.attributes_for(:answer, :user => admin, :question => question) }

  # it "creates an answer in an approved question" do
  #   count = question.answers.count
    
  #   post question_answers_path(question), :answer => answer_attrs,
  #                                         :auth_token => admin.authentication_token,
  #                                         :format => "json"

  #   response.status.should == 201
  #   question.answers.count.should == count+1
    
  #   json = decode_json(response.body)['answer']
  #   json['id'].should_not be_nil
  #   json['content'].should == answer_attrs[:content]
  #   json['user_id'].should == admin.id
  #   json['question_id'].should == question.id
  #   json['initial_probability'].should == answer_attrs[:initial_probability]
  #   json['current_probability'].should == answer_attrs[:initial_probability]
  #   json['bet_total'].should == 0
  #   json['correct'].should be_nil
  #   json['judged_at'].should be_nil
  #   json['judge_id'].should be_nil
  # end

  # it "updates an answer in an approved question" do
  #   put question_answer_path(question, answer), :answer => { :content => "updated content" },
  #                                               :auth_token => admin.authentication_token,
  #                                               :format => "json"

  #   response.status.should == 204

  #   answer.reload
  #   answer.content.should == "updated content"
  # end


  # it "deletes an answer in an approved question" do
  #   answer #trigger answer creation
  #   count = question.answers.count

  #   delete question_answer_path(question, answer),
  #          :auth_token => admin.authentication_token,
  #          :format => "json"
    
  #   response.status.should == 204
  #   question.answers.count.should == count - 1
  # end

  it "judges an answer" do
    put judge_question_answer_path(question, answer), :answer => { :correct => "true" },
                                                      :auth_token => admin.authentication_token,
                                                      :format => "json"

    answer.reload
    answer.should be_correct
    answer.judged_at.should_not be_nil
    answer.judge.should == admin
  end


end
