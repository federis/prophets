require 'spec_helper'
require 'cancan/matchers'

describe "As a normal user," do
  
  extend AbilityHelpers

  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }
  let(:ability) { Ability.new(user) }

  let(:own_league){ FactoryGirl.build(:league, :user => user) }
  let(:not_own_league){ FactoryGirl.build(:league, :user => other_user) }
  can_perform_actions("a league of their own", :create){ own_league }
  cannot_perform_actions("a league owned by someone else", :create, :update, :destroy){ not_own_league }
  
  context "in a public league" do
    let(:league){ FactoryGirl.create(:league, :priv => false) }
    let(:ability) { Ability.new(user, league) }
    
    let(:own_membership){ FactoryGirl.build(:membership, :league => league, :user => user) }
    can_perform_actions("their own membership", :read, :create, :destroy){ own_membership }

    let(:own_admin_membership){ FactoryGirl.build(:membership, :league => league, :user => user, :role => Membership::ROLES[:admin]) }
    cannot_perform_actions("their own admin membership", :create){ own_admin_membership }

    let(:not_own_membership){ FactoryGirl.build(:membership, :league => league, :user => other_user) }
    cannot_perform_actions("a membership for another user", :create, :destroy){ not_own_membership }

    context "where user is a member" do
      before do
        league.users << user
      end

      can_perform_actions("the league", :read){ league }        
      can_perform_actions("", :read_approved_questions){ league }
      cannot_perform_actions("", :read_unapproved_questions, :read_all_questions){ league }

      let(:own_league_comment){ FactoryGirl.build(:comment, :for_league, :user => user, :commentable => league) }
      can_perform_actions("league comments", :create, :update, :destroy){ own_league_comment }
      let(:own_question_comment){ FactoryGirl.build(:comment, :for_question, :user => user, :commentable => league) }
      can_perform_actions("question comments", :create, :update, :destroy){ own_question_comment }
      can_perform_actions("comments", :index){ Comment }

      let(:not_own_league_comment){ FactoryGirl.build(:comment, :for_league, :commentable => league) }
      cannot_perform_actions("league comments owned by another user", :create, :update, :destroy){ not_own_league_comment }
      let(:not_own_question_comment){ FactoryGirl.build(:comment, :for_question, :commentable => league) }
      cannot_perform_actions("question comments owned by another user", :create, :update, :destroy){ not_own_question_comment }
    end

    context "where user is not a member" do
      let(:question){ FactoryGirl.build(:question, :user => user, :league => league) }
      cannot_perform_actions("questions", :create, :update, :destroy){ question }

      can_perform_actions("the league", :read){ league }        
      can_perform_actions("", :read_approved_questions){ league }
      cannot_perform_actions("", :read_unapproved_questions, :read_all_questions){ league }

      let(:own_league_comment){ FactoryGirl.build(:comment, :for_league, :user => user, :commentable => league) }
      cannot_perform_actions("league comments", :create, :update, :destroy){ own_league_comment }
      let(:own_question_comment){ FactoryGirl.build(:comment, :for_question, :user => user, :commentable => league) }
      cannot_perform_actions("question comments", :create, :update, :destroy){ own_question_comment }
      cannot_perform_actions("comments", :index){ Comment }
    end
  end

  context "in a private league" do
    let(:league){ FactoryGirl.create(:league, :private) }
    let(:ability) { Ability.new(user, league) }

    let(:own_membership){ FactoryGirl.build(:membership, :league => league, :user => user) }
    can_perform_actions("their own membership", :read, :create, :destroy){ own_membership }

    let(:own_admin_membership){ FactoryGirl.build(:membership, :league => league, :user => user, :role => Membership::ROLES[:admin]) }
    cannot_perform_actions("their own admin membership", :create){ own_admin_membership }

    let(:not_own_membership){ FactoryGirl.build(:membership, :league => league, :user => other_user) }
    cannot_perform_actions("a membership for another user", :create, :destroy){ not_own_membership }


    context "where user is a member" do
      before do
        league.users << user
      end

      let(:membership_in_league){ user.membership_in_league(league) }

      can_perform_actions("the league", :read, :read_approved_questions){ league }
      cannot_perform_actions("the league", :create, :update, :destroy, :read_unapproved_questions, :read_all_questions){ league }
      cannot_perform_actions("", :read_unapproved_questions, :read_all_questions){ league }

      let(:own_approved_question){ FactoryGirl.build(:question, :user => user, :league => league, :approved_at => Time.now) }
      cannot_perform_actions("questions owned by user", :create, :approve, :update, :destroy){ own_approved_question }

      let(:own_unapproved_question){ FactoryGirl.build(:question, :user => user, :league => league, :approver => nil, :approved_at => nil) }
      cannot_perform_actions("questions owned by user", :approve, :update){ own_approved_question }
      can_perform_actions("unapproved questions", :create, :destroy){ own_unapproved_question }

      let(:answer){ FactoryGirl.build(:answer, :question => own_approved_question) }
      let(:bet){ FactoryGirl.build(:bet, :membership => membership_in_league, :answer => answer) }
      can_perform_actions("bets", :create){ bet }
      can_perform_actions("bets", :index){ Bet }
      cannot_perform_actions("bets", :destroy){ bet }

      let(:not_own_bet){ FactoryGirl.build(:bet, :answer => answer) }
      cannot_perform_actions("bets owned by someone else", :create, :destroy){ not_own_bet }

      context "in an approved question created by the user" do
        let(:answer){ FactoryGirl.build(:answer, :question => own_approved_question) }  
        cannot_perform_actions("answers", :create, :update, :destroy, :judge){ answer }
      end

      context "in an unapproved question created by the user" do
        let(:answer){ FactoryGirl.build(:answer, :user => user, :question => own_unapproved_question) }  
        can_perform_actions("answers", :create, :update, :destroy){ answer }
        cannot_perform_actions("answers", :judge){ answer }

        let(:not_own_answer){ FactoryGirl.build(:answer, :question => own_unapproved_question) }  
        cannot_perform_actions("answer owned by someone else", :create, :update, :destroy, :judge){ not_own_answer }
      end

      context "in an unapproved question created by someone else" do
        let(:question){ FactoryGirl.build(:question, :league => league, :approver => nil, :approved_at => nil) }
        let(:answer){ FactoryGirl.build(:answer, :question => question) }
        cannot_perform_actions("answers", :create, :update, :destroy, :judge){ answer }
      end

    end

    context "where user is not a member" do
      cannot_perform_actions("the league", :read, :create, :update, :destroy){ league }
      cannot_perform_actions("", :read_approved_questions, :read_unapproved_questions, :read_all_questions){ league }

      let(:own_approved_question){ FactoryGirl.build(:question, :user => user, :league => league, :approved_at => Time.now) }
      cannot_perform_actions("questions owned by user", :read, :create, :approve, :update, :destroy){ own_approved_question }

      let(:own_unapproved_question){ FactoryGirl.build(:question, :user => user, :league => league, :approver => nil, :approved_at => nil) }
      cannot_perform_actions("questions owned by user", :read, :create, :destroy, :approve, :update){ own_approved_question }

      let(:answer){ FactoryGirl.build(:answer, :question => own_approved_question) }
      let(:bet){ FactoryGirl.build(:bet, :answer => answer, :membership => FactoryGirl.build(:membership, :user => user)) }
      cannot_perform_actions("bets", :create, :destroy){ bet }
      cannot_perform_actions("bets", :index){ Bet }

      let(:not_own_bet){ FactoryGirl.build(:bet, :answer => answer) }
      cannot_perform_actions("bets", :create, :destroy){ not_own_bet }

      context "in an approved question created by the user" do
        let(:answer){ FactoryGirl.build(:answer, :question => own_approved_question) }  
        cannot_perform_actions("answers", :create, :update, :destroy){ answer }
      end

      context "in an unapproved question created by the user" do
        let(:answer){ FactoryGirl.build(:answer, :question => own_unapproved_question) }  
        cannot_perform_actions("answers", :create, :update, :destroy){ answer }
      end
      
    end
  end


end