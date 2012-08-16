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

    response.status.should == 201

    json = decode_json(response.body)['league']
    json['id'].should_not be_nil
    json['name'].should == league_attrs[:name]
  end

  it "provides error messages when league is invalid" do
    post leagues_path, :league => league_attrs.except(:name), 
                         :auth_token => auth_token,
                         :format => "json"

    response.status.should == 422

    json = decode_json(response.body)
    json["errors"].should include("name")
  end

  it "lists the user's leagues" do
    league_where_not_member = FactoryGirl.create(:league, :priv => false)
    public_league = FactoryGirl.create(:league_with_member, :priv => false, :member => user)
    league_where_member = FactoryGirl.create(:league_with_member, :priv => true, :member => user)
    league_where_admin = FactoryGirl.create(:league_with_admin, :priv => true, :admin => user)

    get leagues_path, :auth_token => auth_token, :format => "json"

    response.status.should == 200

    json = decode_json(response.body)
    
    league_ids = json.map{|l| l["league"]["id"] }
    league_ids.should include(public_league.id)
    league_ids.should include(league_where_member.id)
    league_ids.should include(league_where_admin.id)
    league_ids.should_not include(league_where_not_member.id)
  end

  it "updates a league" do
    league = FactoryGirl.create(:league_with_admin, :admin => user)

    put league_path(league), :league => { :name => "updated name" },
                             :auth_token => auth_token,
                             :format => "json"

    response.status.should == 204
  end

  # it "provides error messages when update fails" do
  #   league = FactoryGirl.create(:league_with_admin, :admin => user)

  #   put league_path(league), :league => { :user_id => user.id+1 },
  #                            :auth_token => auth_token,
  #                            :format => "json"
  #   debugger                        
  #   response.status.should == 422

  #   json = decode_json(response.body)
  #   json["errors"].should include("user")
  # end

end
