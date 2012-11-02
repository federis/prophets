require 'spec_helper'

describe "As a normal user, Comments" do
  let(:user){ FactoryGirl.create(:user) }
  let(:league){ FactoryGirl.create(:league_with_member, :member => user) }
  let(:comment){ FactoryGirl.create(:comment, :for_league, :commentable => league, :user => user) }
  let(:comment_attrs){ FactoryGirl.attributes_for(:comment, :for_league, :commentable => league, :user => user) }

  it "indexes comments in a league" do
    c1 = FactoryGirl.create(:comment, :for_league, :commentable => league)
    c2 = FactoryGirl.create(:comment, :for_league, :commentable => league)
    c3 = FactoryGirl.create(:comment, :for_league)

    get league_comments_path(league), :auth_token => user.authentication_token,
                                      :format => "json"

    response.status.should == 200
    json = decode_json(response.body) 
    comment_ids = json.map{|l| l["comment"]["id"] }
    comment_ids.should include(c1.id)
    comment_ids.should include(c2.id)
    comment_ids.should_not include(c3.id)
  end

  it "creates a comment in a league" do
    count = league.comments.count
    
    post league_comments_path(league), :comment => comment_attrs,
                                         :auth_token => user.authentication_token,
                                         :format => "json"

    response.status.should == 201
    league.comments.count.should == count+1
    
    json = decode_json(response.body)['comment']
    json['id'].should_not be_nil
    json['comment'].should == comment_attrs[:comment]
    json['user_name'].should == user.name
    json['league_id'].should == league.id
  end

  it "updates a comment in a league" do
    put league_comment_path(league, comment), :comment => { :comment => "updated comment" },
                                                :auth_token => user.authentication_token,
                                                :format => "json"

    response.status.should == 204

    comment.reload
    comment.comment.should == "updated comment"
  end


  it "deletes a comment in a league" do
    comment #trigger comment creation
    count = league.comments.count

    delete league_comment_path(league, comment),
           :auth_token => user.authentication_token,
           :format => "json"
    
    response.status.should == 204
    league.comments.count.should == count - 1
  end

end
