class Ability
  include CanCan::Ability

  def initialize(user, league=nil)
    unless user.nil?
      can :create, League, :user_id => user.id
      can [:read, :read_currently_running_questions], League, :priv => false
      can [:read, :destroy, :update], Membership, :user_id => user.id
      can :create, Membership, :user_id => user.id, :role => Membership::ROLES[:member]
      #can :read, Question, :league => { :priv => false }
      can :index, ActsAsTaggableOn::Tag

      unless league.nil?
        if user.is_member_of_league?(league)
          can [:read, :read_currently_running_questions], League
          can :show, Question do |q| 
            q.approved? 
          end
          can [:create, :update, :destroy], Question, :approver_id => nil, :approved_at => nil, :user_id => user.id, :league_id => league.id
          can [:create, :update, :destroy], Answer, :question => { :user_id => user.id, :approved_at => nil, :league_id => league.id }, :user_id => user.id
          can :index, Bet
          can :create, Bet, :membership => { :user_id => user.id, :league_id => league.id }, :answer => {:question => {:league_id => league.id }}

          can :index, Comment
          can [:create, :update, :destroy], Comment, :user_id => user.id
        end

        if user.is_admin_of_league?(league)
          can :manage, League
          can :manage, Membership
          can :manage, Question
          can :manage, Answer
          can :manage, Bet
          can :manage, Comment
        end
      end

      if user.superuser == 1
        can :access, :rails_admin
        can :dashboard
        can :manage, :all
      end
    end
    
  end
end
