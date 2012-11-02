require 'spec_helper'

describe "As a normal user, Comments" do
  let(:user){ FactoryGirl.create(:user) }
  let(:league){ FactoryGirl.create(:league_with_member, :member => user) }
  let(:question){ FactoryGirl.create(:question, :league => league)}
  let(:comment){ FactoryGirl.create(:comment, :for_question, :commentable => question, :user => user) }
  let(:comment_attrs){ FactoryGirl.attributes_for(:comment, :for_question, :commentable => question, :user => user) }

  it "indexes comments in a question" do
    c1 = FactoryGirl.create(:comment, :for_question, :commentable => question)
    c2 = FactoryGirl.create(:comment, :for_question, :commentable => question)
    c3 = FactoryGirl.create(:comment, :for_question)

    get question_comments_path(question), :auth_token => user.authentication_token,
                                      :format => "json"

    response.status.should == 200
    json = decode_json(response.body) 
    comment_ids = json.map{|l| l["comment"]["id"] }
    comment_ids.should include(c1.id)
    comment_ids.should include(c2.id)
    comment_ids.should_not include(c3.id)
  end

  it "creates a comment in a question" do
    count = question.comments.count
    
    post question_comments_path(question), :comment => comment_attrs,
                                         :auth_token => user.authentication_token,
                                         :format => "json"

    response.status.should == 201
    question.comments.count.should == count+1
    
    json = decode_json(response.body)['comment']
    json['id'].should_not be_nil
    json['comment'].should == comment_attrs[:comment]
    json['user_name'].should == user.name
    json['question_id'].should == question.id
  end

  it "updates a comment in a question" do
    put question_comment_path(question, comment), :comment => { :comment => "updated comment" },
                                                :auth_token => user.authentication_token,
                                                :format => "json"

    response.status.should == 204

    comment.reload
    comment.comment.should == "updated comment"
  end


  it "deletes a comment in a question" do
    comment #trigger comment creation
    count = question.comments.count

    delete question_comment_path(question, comment),
           :auth_token => user.authentication_token,
           :format => "json"
    
    response.status.should == 204
    question.comments.count.should == count - 1
  end

end
