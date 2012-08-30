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

  context "a normal user" do
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
      end

      context "where user is not a member" do
        let(:question){ FactoryGirl.build(:question, :user => user, :league => league) }
        cannot_perform_actions("questions", :create, :update, :destroy){ question }

        can_perform_actions("the league", :read){ league }        
        can_perform_actions("", :read_approved_questions){ league }
        cannot_perform_actions("", :read_unapproved_questions, :read_all_questions){ league }
      end
    end

    context "in a private league" do
      let(:league){ FactoryGirl.create(:league, :priv => true) }
      let(:ability) { Ability.new(user, league) }

      let(:own_membership){ FactoryGirl.build(:membership, :league => league, :user => user) }
      cannot_perform_actions("their own membership", :create){ own_membership }
      can_perform_actions("their own membership", :read, :destroy){ own_membership }

      let(:own_admin_membership){ FactoryGirl.build(:membership, :league => league, :user => user, :role => Membership::ROLES[:admin]) }
      cannot_perform_actions("their own admin membership", :create){ own_admin_membership }

      let(:not_own_membership){ FactoryGirl.build(:membership, :league => league, :user => other_user) }
      cannot_perform_actions("a membership for another user", :create, :destroy){ not_own_membership }


      context "where user is a member" do
        before do
          league.users << user
        end

        can_perform_actions("the league", :read, :read_approved_questions){ league }
        cannot_perform_actions("the league", :create, :update, :destroy, :read_unapproved_questions, :read_all_questions){ league }
        cannot_perform_actions("", :read_unapproved_questions, :read_all_questions){ league }

        let(:own_approved_question){ FactoryGirl.build(:question, :user => user, :league => league, :approved_at => Time.now) }
        cannot_perform_actions("questions owned by user", :create, :approve, :update, :destroy){ own_approved_question }

        let(:own_unapproved_question){ FactoryGirl.build(:question, :user => user, :league => league, :approver => nil, :approved_at => nil) }
        cannot_perform_actions("questions owned by user", :approve, :update){ own_approved_question }
        can_perform_actions("unapproved questions", :create, :destroy){ own_unapproved_question }

        let(:answer){ FactoryGirl.build(:answer, :question => own_approved_question) }
        let(:bet){ FactoryGirl.build(:bet, :user => user, :answer => answer) }
        can_perform_actions("bets", :create){ bet }
        cannot_perform_actions("bets", :destroy){ bet }

        let(:not_own_bet){ FactoryGirl.build(:bet, :answer => answer) }
        cannot_perform_actions("bets owned by someone else", :create, :destroy){ not_own_bet }

        context "in an approved question created by the user" do
          let(:answer){ FactoryGirl.build(:answer, :question => own_approved_question) }  
          cannot_perform_actions("answers", :create, :update, :destroy){ answer }
        end

        context "in an unapproved question created by the user" do
          let(:answer){ FactoryGirl.build(:answer, :user => user, :question => own_unapproved_question) }  
          can_perform_actions("answers", :create, :update, :destroy){ answer }

          let(:not_own_answer){ FactoryGirl.build(:answer, :question => own_unapproved_question) }  
          cannot_perform_actions("answer owned by someone else", :create, :update, :destroy){ not_own_answer }
        end

        context "in an unapproved question created by someone else" do
          let(:question){ FactoryGirl.build(:question, :league => league, :approver => nil, :approved_at => nil) }
          let(:answer){ FactoryGirl.build(:answer, :question => question) }
          cannot_perform_actions("answers", :create, :update, :destroy){ answer }

          let(:bet){ FactoryGirl.build(:bet, :user => user, :answer => answer) }
          cannot_perform_actions("bets", :create){ bet }
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
        let(:bet){ FactoryGirl.build(:bet, :user => user, :answer => answer) }
        cannot_perform_actions("bets", :create, :destroy){ bet }

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


  context "a league admin" do
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
      can_perform_actions("answers", :create, :update, :destroy){ answer }

      let(:bet){ FactoryGirl.build(:bet, :answer => answer) }
      can_perform_actions("bets", :create, :destroy){ bet }
      
    end
  end


  context "a super user" do

  end

end