require 'spec_helper'

describe "Leagues API" do
  let(:user){ FactoryGirl.create(:user) }
  let(:auth_token){ user.authentication_token }
  let(:league_attrs){ FactoryGirl.attributes_for(:league) }
  it "creates a league" do
    expect{
      post leagues_path, :league => league_attrs, 
                         :auth_token => auth_token,
                         :format => "json"
    }.to change{ League.count }.by(1)

    json = decode_json(response.body)['league']

    json['id'].should_not be_nil
    json['name'].should == league_attrs[:name]
    response.status.should == 201
  end

  it "provides error messages when league is invalid" do
    post leagues_path, :league => league_attrs.except(:name), 
                         :auth_token => auth_token,
                         :format => "json"

    json = decode_json(response.body)

    json["errors"].should include("name")
    response.status.should == 422
  end
end
