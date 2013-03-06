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
end