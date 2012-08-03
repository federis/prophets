require 'spec_helper'

describe RegistrationsController do
  before :each do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  it "creates a user via JSON" do
    expect{
      post :create, :user => FactoryGirl.attributes_for(:user).merge(:password_confirmation => "password"), 
                     :registration_secret => RegistrationsController::REGISTRATION_SECRET, 
                     :format => "json"
    }.to change{ User.count }.by(1)
  end

  it "requires registration secret for user creation via JSON" do
    count = User.count
    expect{
      post :create, :user => FactoryGirl.attributes_for(:user).merge(:password_confirmation => "password"), :format => "json"
    }.to raise_error

    User.count.should == count
  end

end
