require 'spec_helper'
require 'cancan/matchers'

describe "As a league admin," do
  
  extend AbilityHelpers

  let(:admin) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }
  let(:ability) { Ability.new(admin) }

  context "in a public league" do
    let(:league) { FactoryGirl.create(:league, :user => admin, :priv => false) } #will automatically get admin privs on create
    let(:ability) { Ability.new(admin, league) }

    can_perform_actions("the league", :manage){ league }
    can_perform_actions("", :read_unapproved_questions, :read_all_questions){ league }

    let(:not_own_membership){ FactoryGirl.build(:membership, :league => league, :user => other_user) }
    can_perform_actions("a membership for another user in private league", :create, :destroy){ not_own_membership }

    let(:question){ FactoryGirl.build(:question, :user => admin, :league => league) }
    can_perform_actions("questions", :approve, :read, :create, :update, :destroy){ question }

    let(:answer){ FactoryGirl.build(:answer, :question => question) }
    can_perform_actions("answers", :create, :update, :destroy){ answer }
  end

  context "in a private league" do
    let(:league) { FactoryGirl.create(:league, :user => admin, :priv => true) } #will automatically get admin privs on create
    let(:ability) { Ability.new(admin, league) }

    can_perform_actions("the league", :manage){ league }
    can_perform_actions("", :read_unapproved_questions, :read_all_questions){ league }

    let(:not_own_membership){ FactoryGirl.build(:membership, :league => league, :user => other_user) }
    can_perform_actions("a membership for another user", :create, :destroy){ not_own_membership }

    let(:question){ FactoryGirl.build(:question, :user => admin, :league => league) }
    can_perform_actions("questions", :approve, :read, :create, :update, :destroy){ question }

    let(:answer){ FactoryGirl.build(:answer, :question => question) }
    can_perform_actions("answers", :create, :update, :destroy, :judge){ answer }

    let(:bet){ FactoryGirl.build(:bet, :answer => answer) }
    can_perform_actions("bets", :create, :destroy){ bet }
    
    let(:league_comment){ FactoryGirl.build(:comment, :for_league) }
    can_perform_actions("league comments", :create, :update, :destroy){ league_comment }
    let(:question_comment){ FactoryGirl.build(:comment, :for_question) }
    can_perform_actions("question comments", :create, :update, :destroy){ question_comment }
  end


end