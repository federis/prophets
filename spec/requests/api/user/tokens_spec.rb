require 'spec_helper'

describe "Tokens API" do
  describe "POST /tokens.json" do
    let(:user){ FactoryGirl.create(:user) }
    it "gives the user with token when valid username & password are provided" do
      post tokens_path, :user => { :email => user.email, :password => user.password }, 
                        :format => "json"
      
      resp_user = decode_json(response.body)['user']
      resp_user['authentication_token'].should == user.authentication_token
      resp_user['id'].should == user.id
      resp_user['email'].should == user.email
    end

    it "doesn't give user with token when invalid username & password are provided" do
      post tokens_path, :user => { :email => user.email, :password => "h4xx0r" }, 
                        :format => "json"
      
      response.status.should == 401
      response.body.should_not include("user")
      response.body.should_not include("authentication_token")
      response.body.should include("error")
    end

  end

  describe "POST /tokens/facebook.json" do
    let(:user){ FactoryGirl.create(:user, :fb_uid => "100004368094432") }
    let(:fb_user_attrs){ {"id"=>"100004368094432", "name"=>"Barbara Amdcfhjiddcb Narayananson", "first_name"=>"Barbara", "middle_name"=>"Amdcfhjiddcb", "last_name"=>"Narayananson", "link"=>"http://www.facebook.com/profile.php?id=100004368094432", "gender"=>"female", "timezone"=>-5, "locale"=>"en_US", "updated_time"=>"2012-09-13T13:18:41+0000"} }

    it "gives the user with token when valid facebook oauth token is provided" do
      fb = mock("Koala::Facebook::API")
      Koala::Facebook::API.stub(:new).and_return(fb)
      fb.stub(:get_object).and_return(fb_user_attrs)

      user #trigger user creation

      post facebook_tokens_path :fb_token => "abc", :format => "json"

      resp_user = decode_json(response.body)['user']
      resp_user['authentication_token'].should == user.authentication_token
      resp_user['id'].should == user.id
      resp_user['email'].should == user.email
    end

    it "doesn't give user with token when invalid facebook oauth token is provided" do
      fb = mock("Koala::Facebook::API")
      Koala::Facebook::API.stub(:new).and_return(fb)
      fb.stub(:get_object).and_raise(Koala::Facebook::APIError)

      post facebook_tokens_path :fb_token => "abc", :format => "json"

      response.status.should == 401
      resp = decode_json(response.body)
      resp.keys.should include("error")
      resp.keys.should_not include("user")
      resp["error"].should == I18n.t('devise.failure.unauthenticated')
      
    end

    it "doesn't give user with token when user with the fb uid doesn't exist" do
      fb = mock("Koala::Facebook::API")
      Koala::Facebook::API.stub(:new).and_return(fb)
      fb.stub(:get_object).and_return(fb_user_attrs)

      post facebook_tokens_path :fb_token => "abc", :format => "json"
      
      response.status.should == 404
      resp = decode_json(response.body)
      resp.keys.should include("error")
      resp.keys.should_not include("user")
      resp["error"].should == I18n.t('tokens.fb_user_not_found')
    end
  end
end
