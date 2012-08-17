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
end
