require 'spec_helper'

describe "Registrations API" do
  it "creates a user" do
    expect{
      post user_registration_path, :user => FactoryGirl.attributes_for(:user).merge(:password_confirmation => "password"), 
                                   :registration_secret => RegistrationsController::REGISTRATION_SECRET, 
                                   :format => "json"
    }.to change{ User.count }.by(1)
  end

  it "requires registration secret for user creation" do
    count = User.count
    expect{
      post user_registration_path, :user => FactoryGirl.attributes_for(:user).merge(:password_confirmation => "password"), :format => "json"
    }.to raise_error

    User.count.should == count
  end
end
