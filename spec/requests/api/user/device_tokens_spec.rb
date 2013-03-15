require 'spec_helper'

describe "As a normal user, DeviceToken" do
  let(:user){ FactoryGirl.create(:user) }
  let(:device_token){ FactoryGirl.create(:device_token) }

  it "creates a device token if no matching token exists" do
    count = DeviceToken.count

    post device_tokens_path, :device_token => { :value => "hereisatoken" },
                             :auth_token => user.authentication_token,
                             :format => "json"

    response.status.should == 201
    DeviceToken.count.should == count + 1

    token = DeviceToken.last
    token.value.should == "HEREISATOKEN"
    token.user.should == user
  end

  it "reassigns existing tokens to a new user" do
    device_token.user.should_not == user
    count = DeviceToken.count

    post device_tokens_path, :device_token => { :value => device_token.value },
                             :auth_token => user.authentication_token,
                             :format => "json"

    response.status.should == 201
    DeviceToken.count.should == count

    token = DeviceToken.last
    token.value.should == device_token.value
    token.user_id.should == user.id
  end

  it "updates the timestamp if token already exists" do
    token = FactoryGirl.create(:device_token, user: user)
    last_updated = token.updated_at
    count = DeviceToken.count

    post device_tokens_path, :device_token => { :value => token.value },
                             :auth_token => user.authentication_token,
                             :format => "json"

    DeviceToken.count.should == count

    token.reload
    token.updated_at.should be > last_updated
  end
  
  it "destroys a token" do
    token = FactoryGirl.create(:device_token, user: user)

    count = DeviceToken.count

    delete device_tokens_path :device_token => { :value => token.value },
                              :auth_token => user.authentication_token,
                              :format => "json"

    response.status.should == 204
    DeviceToken.count.should == count - 1
  end
end
