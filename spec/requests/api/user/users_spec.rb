require "spec_helper"

describe "As a normal user, Users" do
  let(:user){ FactoryGirl.create(:user) }
  describe "#show" do
    it "shows the user" do
      get user_path(user), :auth_token => user.authentication_token,
                           :format => "json"

      response.status.should == 200

      json = decode_json(response.body)['user']
      json['id'].should_not be_nil
      json['email'].should == user.email
      json['name'].should == user.name
      json['wants_notifications'].should == user.wants_notifications
      json['wants_new_question_notifications'].should == user.wants_new_question_notifications
    end
  end


  describe "POST /users/facebook.json" do
    let(:user){ FactoryGirl.create(:user, :without_fb) }
    let(:fb_user_attrs){ {"id"=>"100004368094432", "name"=>"Barbara Amdcfhjiddcb Narayananson", "first_name"=>"Barbara", "middle_name"=>"Amdcfhjiddcb", "last_name"=>"Narayananson", "link"=>"http://www.facebook.com/profile.php?id=100004368094432", "gender"=>"female", "timezone"=>-5, "locale"=>"en_US", "updated_time"=>"2012-09-13T13:18:41+0000"} }

    it "gives the user with token and connects the user to the fb uid when valid facebook oauth token is provided" do
      fb = mock("Koala::Facebook::API")
      Koala::Facebook::API.stub(:new).and_return(fb)
      fb.stub(:get_object).and_return(fb_user_attrs)
      fb.stub(:access_token).and_return("abc")

      user.fb_uid.should == nil

      next_month = 1.month.from_now
      post facebook_users_path, :fb_token => "abc", :fb_token_expires_at => next_month, 
                                :auth_token => user.authentication_token,
                                :format => "json"

      user.reload
      resp_user = decode_json(response.body)['user']
      resp_user['authentication_token'].should == user.authentication_token
      resp_user['id'].should == user.id
      resp_user['email'].should == user.email
      resp_user['fb_uid'].should == user.fb_uid

      user.fb_uid.should == fb_user_attrs["id"]
      user.fb_token.should == "abc"
      user.fb_token_expires_at.iso8601.should == next_month.iso8601
    end

    it "doesn't give user with token when invalid facebook oauth token is provided and doesn't connect the fb uid" do
      fb = mock("Koala::Facebook::API")
      Koala::Facebook::API.stub(:new).and_return(fb)
      fb.stub(:get_object).and_raise(Koala::Facebook::APIError)

      post facebook_users_path, :fb_token => "abc", :fb_token_expires_at => 1.month.from_now, 
                                :auth_token => user.authentication_token,
                                :format => "json"

      response.status.should == 401
      resp = decode_json(response.body)
      resp.keys.should include("error")
      resp.keys.should_not include("user")
      resp.keys.should include("error")

      user.reload
      user.fb_uid.should be_nil      
    end

    it "doesn't give connect the user to the fb uid when a user with that fb uid already exists" do
      existing_user = FactoryGirl.create(:user, fb_uid: fb_user_attrs['id'])

      fb = mock("Koala::Facebook::API")
      Koala::Facebook::API.stub(:new).and_return(fb)
      fb.stub(:get_object).and_return(fb_user_attrs)
      fb.stub(:access_token).and_return("abc")

      user.fb_uid.should == nil

      post facebook_users_path, :fb_token => "abc", :fb_token_expires_at => 1.month.from_now, 
                                :auth_token => user.authentication_token,
                                :format => "json"

      user.reload
      response.status.should == 422
      resp = decode_json(response.body)
      resp.keys.should include("errors")
      resp.keys.should_not include("user")
      resp["errors"].should include("Facebook account has already been taken")
    end
  end
end