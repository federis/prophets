class Ability
  include CanCan::Ability

  def initialize(user, league=nil)
    unless user.nil?
      # #any user
      # can :create, League, :user_id => user.id
      # can [:read, :read_approved_questions], League, :priv => false
      # can [:read, :destroy], Membership, :user_id => user.id
      # can :create, Membership, :user_id => user.id, :league => { :priv => false }, :role => Membership::ROLES[:member]
      # can :read, Question, :league => { :priv => false }

      # #where user is a league member
      # can [:read, :read_approved_questions], League, :memberships => { :user_id => user.id }
      # can :read, Question, :league => { :memberships => { :user_id => user.id } }
      # can [:create, :destroy], Question, :approver_id => nil, :approved_at => nil, :user_id => user.id, :league => { :memberships => { :user_id => user.id } }
      # #can :create, Answer, :question => { :user_id => user.id, :approved_at => nil }

      # #where user is league admin
      # can :manage, League, :memberships => { :user_id => user.id, :role => Membership::ROLES[:admin] }
      # can :manage, Membership, :league => { :memberships => { :user_id => user.id, :role => Membership::ROLES[:admin] } }
      # can :manage, Question, :league => { :memberships => { :user_id => user.id, :role => Membership::ROLES[:admin] } }
      # #can :manage, Answer do |answer|
      # #  user.is_admin_of_league?(answer.question.league)
      # #end

      can :create, League, :user_id => user.id
      can [:read, :read_approved_questions], League, :priv => false
      can [:read, :destroy], Membership, :user_id => user.id
      can :create, Membership, :user_id => user.id, :league => { :priv => false }, :role => Membership::ROLES[:member]
      #can :read, Question, :league => { :priv => false }

      unless league.nil?
        if user.is_member_of_league?(league)
          can [:read, :read_approved_questions], League
          can :show, Question do |q| 
            q.approved? 
          end
          can [:create, :destroy], Question, :approver_id => nil, :approved_at => nil, :user_id => user.id, :league_id => league.id
          can [:create, :update, :destroy], Answer, :question => { :user_id => user.id, :approved_at => nil }, :user_id => user.id
          can :index, Bet
          can :create, Bet do |b|
            b.user == user && b.answer.question.approved?
          end

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
    end
    
  end
end
