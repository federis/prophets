class Ability
  include CanCan::Ability

  def initialize(user)
    unless user.nil?
      #any user
      can :create, League, :user_id => user.id
      can :read, League, :priv => false
      can [:read, :destroy], Membership, :user_id => user.id
      can :create, Membership, :user_id => user.id, :league => { :priv => false }, :role => Membership::ROLES[:member]
      can :read, Question, :league => { :priv => false }

      #where user is a league member
      can :read, League, :memberships => { :user_id => user.id }
      can :read, Question, :league => { :memberships => { :user_id => user.id } }
      can :create, Question, :approver_id => nil, :approved_at => nil, :user_id => user.id, :league => { :memberships => { :user_id => user.id } }

      #where user is league admin
      can :manage, League, :memberships => { :user_id => user.id, :role => Membership::ROLES[:admin] }
      can :manage, Membership, :league => { :memberships => { :user_id => user.id, :role => Membership::ROLES[:admin] } }
      can :manage, Question, :league => { :memberships => { :user_id => user.id, :role => Membership::ROLES[:admin] } }
    end
    
  end
end
