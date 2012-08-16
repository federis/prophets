require 'spec_helper'

describe "Memberships" do
  let(:user){ FactoryGirl.create(:user) }
  let(:league){ FactoryGirl.create(:league_with_membership, :user => user) }

  it "creates a league membership" do
    expect{
      post leagues_path, :league => league_attrs, 
                         :auth_token => auth_token,
                         :format => "json"
    }.to change{ League.count }.by(1)

    response.status.should == 201

    json = decode_json(response.body)['league']
    json['id'].should_not be_nil
    json['name'].should == league_attrs[:name]
  end
end
