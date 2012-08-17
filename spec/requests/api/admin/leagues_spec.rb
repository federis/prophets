require 'spec_helper'

describe "As an admin, Leagues" do
  let(:user){ FactoryGirl.create(:user) }
  let(:auth_token){ user.authentication_token }
  let(:league_attrs){ FactoryGirl.attributes_for(:league) }
  let(:league){ FactoryGirl.create(:league_with_admin, :admin => user) }

  it "updates a league" do
    put league_path(league), :league => { :name => "updated name" },
                             :auth_token => auth_token,
                             :format => "json"

    response.status.should == 204
  end

end
