require 'spec_helper'

describe "Registrations API" do
  it "creates a user" do
    expect{
      post user_registration_path, :user => FactoryGirl.attributes_for(:user).merge(:password_confirmation => "password"), 
                                   :registration_secret => RegistrationsController::REGISTRATION_SECRET, 
                                   :format => "json"
    }.to change{ User.count }.by(1)

    user = User.last
    resp_user = decode_json(response.body)['user']
    resp_user['authentication_token'].should == user.authentication_token
    resp_user['id'].should == user.id
    resp_user['email'].should == user.email
  end

  it "requires registration secret for user creation" do
    count = User.count
    expect{
      post user_registration_path, :user => FactoryGirl.attributes_for(:user).merge(:password_confirmation => "password"), :format => "json"
    }.to raise_error

    User.count.should == count
  end

  it "creates a user with facebook" do
    fb_user_attrs = Hashie::Mash.new({"id"=>"100004368094432", "name"=>"Barbara Amdcfhjiddcb Narayananson", "first_name"=>"Barbara", "middle_name"=>"Amdcfhjiddcb", "last_name"=>"Narayananson", "link"=>"http://www.facebook.com/profile.php?id=100004368094432", "gender"=>"female", "timezone"=>-5, "locale"=>"en_US", "updated_time"=>"2012-09-13T13:18:41+0000"})
    user_attrs = FactoryGirl.attributes_for(:user).merge(:password_confirmation => "password", :fb_uid => fb_user_attrs['id'], :fb_token => "123", :fb_token_expires_at => 1.week.from_now)

    fb = mock("Koala::Facebook::API")
    Koala::Facebook::API.stub(:new).and_return(fb)
    fb.stub(:get_object).and_return(fb_user_attrs)

    count = User.count

    post user_registration_path, :user =>  user_attrs,
                                 :registration_secret => RegistrationsController::REGISTRATION_SECRET, 
                                 :format => "json"

    User.count.should == count + 1
    user = User.last
    user.fb_uid.should == fb_user_attrs["id"]
    user.fb_token.should == "123"

    resp_user = decode_json(response.body)['user']
    resp_user['authentication_token'].should == user.authentication_token
    resp_user['id'].should == user.id
    resp_user['email'].should == user.email
  end

  it "doesn't create user if facebook token is invalid" do
    user_attrs = FactoryGirl.attributes_for(:user).merge(:password_confirmation => "password", :fb_uid => "1234", :fb_token => "123", :fb_token_expires_at => 1.week.from_now)

    fb = mock("Koala::Facebook::API")
    Koala::Facebook::API.stub(:new).and_return(fb)
    fb.stub(:get_object).and_raise(Koala::Facebook::APIError)

    count = User.count

    post user_registration_path, :user =>  user_attrs,
                                 :registration_secret => RegistrationsController::REGISTRATION_SECRET, 
                                 :format => "json"


    response.status.should == 422
    User.count.should == count
  end
end
