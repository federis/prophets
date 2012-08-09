require 'spec_helper'
require 'cancan/matchers'

describe Ability do
  
  def self.can_perform_actions(resource_name, *actions, &resource_block)
    actions.each do |action|
      it "can #{action} #{resource_name}" do
        resource = instance_eval &resource_block
        ability.should be_able_to(action, resource)
      end
    end
  end
  
  def self.cannot_perform_actions(resource_name, *actions, &resource_block)
    actions.each do |action|
      it "cannot #{action} #{resource_name}" do
        resource = instance_eval &resource_block
        ability.should_not be_able_to(action, resource)
      end
    end
  end

  context "an anonymous user" do
    let(:user) { nil }
    let(:ability) { Ability.new(user) }

    let(:owned_league){ League.new(FactoryGirl.attributes_for(:league)) }
    can_perform_actions("trips owned by the user", :create){  }
    cannot_perform_actions("trips not owned by the user", :create, :update, :destroy){ not_owned_trip }
  end

  context "a logged in user" do
    let(:user) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }
    let(:ability) { Ability.new(user) }
  end

  context "a super user" do

  end

end