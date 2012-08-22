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

  # context "an anonymous user" do
  #   let(:user) { nil }
  #   let(:ability) { Ability.new(user) }
  #   let(:public_league) { League.new(:priv => false) }
  #   let(:private_league) { l=League.new; l.priv=true; l }

  #   cannot_perform_actions("a league", :read){ League }
  #   cannot_perform_actions("a private league", :read){ private_league }
  #   cannot_perform_actions("a league", :create, :update, :destroy){ League }

  #   let(:question_in_public_league){ FactoryGirl.build(:question, :league => public_league) }
  #   cannot_perform_actions("questions in a public league", :read, :create, :update, :destroy){ question_in_public_league }
  # end

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
    
    let(:league_where_member) { FactoryGirl.create(:league_with_member, :priv => true, :member => user) }
    can_perform_actions("a private league the user is a member of", :read, :read_approved_questions){ league_where_member }
    cannot_perform_actions("a league the user is a member of", :create, :update, :destroy, :read_unapproved_questions, :read_all_questions){ league_where_member }

    let(:own_membership_in_private_league){ FactoryGirl.build(:membership, :league => private_league, :user => user) }
    cannot_perform_actions("their own membership in private league", :create){ own_membership_in_private_league }
    can_perform_actions("their own membership in private league", :destroy){ own_membership_in_private_league }

    let(:not_own_membership_in_private_league){ FactoryGirl.build(:membership, :league => private_league, :user => other_user) }
    cannot_perform_actions("a membership for another user in private league", :create, :destroy){ not_own_membership_in_private_league }

    let(:own_membership_in_public_league){ FactoryGirl.build(:membership, :league => public_league, :user => user) }
    can_perform_actions("their own membership in public league", :create, :destroy){ own_membership_in_public_league }

    let(:not_own_membership_in_public_league){ FactoryGirl.build(:membership, :league => public_league, :user => other_user) }
    cannot_perform_actions("a membership for another user in public league", :create, :destroy){ not_own_membership_in_public_league }

    let(:question_in_league_where_member){ FactoryGirl.build(:question, :user => user, :league => league_where_member) }
    cannot_perform_actions("questions in a league where the user is a member", :approve, :update, :destroy){ question_in_league_where_member }
    can_perform_actions("questions in a league where the user is a member", :read){ question_in_league_where_member }

    let(:unapproved_question_in_league_where_member){ FactoryGirl.build(:question, :user => user, :league => league_where_member, :approver => nil, :approved_at => nil) }
    can_perform_actions("unapproved questions in a league where the user is a member", :create){ unapproved_question_in_league_where_member }

    let(:question_in_public_league){ FactoryGirl.build(:question, :user => user, :league => public_league) }
    cannot_perform_actions("questions in a public league", :create, :update, :destroy){ question_in_public_league }
  end


  context "a league admin" do
    let(:admin) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }
    let(:ability) { Ability.new(admin) }
    let(:public_league) { FactoryGirl.create(:league, :user => admin) } #will automatically get admin privs on create
    let(:private_league) { FactoryGirl.create(:league, :user => admin, :priv => true) }

    can_perform_actions("a league the user is an admin of", :manage, :read_unapproved_questions, :read_all_questions){ private_league }

    let(:not_own_membership_in_private_league){ FactoryGirl.build(:membership, :league => private_league, :user => other_user) }
    can_perform_actions("a membership for another user in private league", :create, :destroy){ not_own_membership_in_private_league }

    let(:not_own_membership_in_public_league){ FactoryGirl.build(:membership, :league => public_league, :user => other_user) }
    can_perform_actions("a membership for another user in public league", :create, :destroy){ not_own_membership_in_public_league }

    let(:question){ FactoryGirl.build(:question, :user => admin, :league => public_league) }
    can_perform_actions("questions", :approve, :read, :create, :update, :destroy){ question }
  end


  context "a super user" do

  end

end