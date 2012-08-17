class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, League, :priv => false

    unless user.nil?
      #any user
      can :create, League, :user_id => user.id
      can [:read, :destroy], Membership, :user_id => user.id
      can :create, Membership, :user_id => user.id, :league => { :priv => false }, :role => Membership::ROLES[:member]

      #where user is a league member
      can :read, League, :memberships => { :user_id => user.id }

      #where user is league admin
      can :manage, League, :memberships => { :user_id => user.id, :role => Membership::ROLES[:admin] }
      can :manage, Membership, :league => { :memberships => { :user_id => user.id, :role => Membership::ROLES[:admin] } }
    end
    
  end
end
