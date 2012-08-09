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

    
    cannot_perform_actions("a league", :create){ League }
  end

  context "a logged in user" do
    let(:user) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }
    let(:ability) { Ability.new(user) }

    let(:owned_league){ l=League.new(FactoryGirl.attributes_for(:league)); l.creator = user; l }
    let(:not_owned_league){ l=League.new(FactoryGirl.attributes_for(:league)); l.creator = other_user; l }

    can_perform_actions("a league of their own", :create){ owned_league }
    cannot_perform_actions("a league owned by someone else", :create){ not_owned_league }
  end

  context "a super user" do

  end

end