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
    let(:public_league) { League.new(:priv => false) }
    let(:private_league) { l=League.new; l.priv=true; l }

    can_perform_actions("a public league", :read){ League }
    cannot_perform_actions("a private league", :read){ private_league }
    cannot_perform_actions("a league", :create, :update, :destroy){ League }
  end

  context "a logged in user" do
    let(:user) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }
    let(:ability) { Ability.new(user) }

    let(:own_league){ FactoryGirl.build(:league, :user => user) }
    let(:not_own_league){ FactoryGirl.build(:league, :user => other_user) }
    can_perform_actions("a league of their own", :create){ own_league }
    cannot_perform_actions("a league owned by someone else", :create, :update, :destroy){ not_own_league }

    let(:public_league){ FactoryGirl.create(:league, :priv => false) }
    can_perform_actions("a public league", :read){ public_league }

    let(:private_league){ FactoryGirl.create(:league, :priv => true) }
    cannot_perform_actions("a private league", :read){ private_league }
    
    let(:league_where_member) do
      l=FactoryGirl.create(:league, :priv => true)
      FactoryGirl.create(:membership, :user => user, :league => l)
      l
    end
    can_perform_actions("a private league the user is a member of", :read){ league_where_member }
    cannot_perform_actions("a league the user is a member of", :create, :update, :destroy){ league_where_member }

    let(:own_membership_in_private_league){ FactoryGirl.build(:membership, :league => private_league, :user => user) }
    cannot_perform_actions("their own membership in private league", :create){ own_membership_in_private_league }
    can_perform_actions("their own membership in private league", :destroy){ own_membership_in_private_league }

    let(:not_own_membership_in_private_league){ FactoryGirl.build(:membership, :league => private_league, :user => other_user) }
    cannot_perform_actions("a membership for another user in private league", :create, :destroy){ not_own_membership_in_private_league }

    let(:own_membership_in_public_league){ FactoryGirl.build(:membership, :league => public_league, :user => user) }
    can_perform_actions("their own membership in public league", :create, :destroy){ own_membership_in_public_league }

    let(:not_own_membership_in_public_league){ FactoryGirl.build(:membership, :league => public_league, :user => other_user) }
    cannot_perform_actions("a membership for another user in public league", :create, :destroy){ not_own_membership_in_public_league }
  end


  context "a league admin" do
    let(:admin) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }
    let(:ability) { Ability.new(admin) }
    let(:public_league) { FactoryGirl.create(:league, :user => admin) } #will automatically get admin privs on create
    let(:private_league) { FactoryGirl.create(:league, :user => admin, :priv => true) }

    can_perform_actions("a league the user is an admin of", :manage){ private_league }

    let(:not_own_membership_in_private_league){ FactoryGirl.build(:membership, :league => private_league, :user => other_user) }
    can_perform_actions("a membership for another user in private league", :create, :destroy){ not_own_membership_in_private_league }

    let(:not_own_membership_in_public_league){ FactoryGirl.build(:membership, :league => public_league, :user => other_user) }
    can_perform_actions("a membership for another user in public league", :create, :destroy){ not_own_membership_in_public_league }

  end


  context "a super user" do

  end

end