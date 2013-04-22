require 'spec_helper'

describe "As a normal user, Comments" do
  let(:user){ FactoryGirl.create(:user) }
  let(:league){ FactoryGirl.create(:league_with_member, :member => user) }
  let(:question){ FactoryGirl.create(:question, :league => league)}
  let(:answer){ FactoryGirl.create(:answer, :question => question, :user => user) }
  let(:membership){ user.membership_in_league(league) }
  let(:bet){ FactoryGirl.create(:bet, :answer => answer, :membership => membership) }

  let(:comment){ FactoryGirl.create(:comment, :for_bet, :commentable => bet, :user => user) }
  let(:comment_attrs){ FactoryGirl.attributes_for(:comment, :for_bet, :commentable => bet, :user => user) }

  it "indexes comments on a bet" do
    c1 = FactoryGirl.create(:comment, :for_bet, :commentable => bet)
    c2 = FactoryGirl.create(:comment, :for_bet, :commentable => bet)
    c3 = FactoryGirl.create(:comment, :for_league)

    get bet_comments_path(bet), :auth_token => user.authentication_token,
                                     :format => "json"

    response.status.should == 200
    json = decode_json(response.body) 
    comment_ids = json.map{|l| l["comment"]["id"] }
    comment_ids.should include(c1.id)
    comment_ids.should include(c2.id)
    comment_ids.should_not include(c3.id)
  end

  it "creates a comment on a bet" do
    count = bet.comments.count
    
    post bet_comments_path(bet), :comment => comment_attrs,
                                      :auth_token => user.authentication_token,
                                      :format => "json"

    response.status.should == 201
    bet.comments.count.should == count+1
    
    json = decode_json(response.body)['comment']
    json['id'].should_not be_nil
    json['comment'].should == comment_attrs[:comment]
    json['user_name'].should == user.name
    json['bet_id'].should == bet.id
  end

  it "updates a comment on a bet" do
    put bet_comment_path(bet, comment), :comment => { :comment => "updated comment" },
                                        :auth_token => user.authentication_token,
                                        :format => "json"

    response.status.should == 204

    comment.reload
    comment.comment.should == "updated comment"
  end


  it "deletes a comment on a bet" do
    comment #trigger comment creation
    count = bet.comments.count

    delete bet_comment_path(bet, comment),
           :auth_token => user.authentication_token,
           :format => "json"
    
    response.status.should == 204
    bet.comments.count.should == count - 1
  end

end
