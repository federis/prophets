class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, League, :priv => false

    unless user.nil?
      #any user
      can :create, League, :user_id => user.id
      can [:read, :delete], LeagueMembership, :user_id => user.id
      can :create, LeagueMembership, :user_id => user.id, :league => { :priv => false }, :role => LeagueMembership::ROLES[:member]

      #where user is a league member
      can :read, League, :league_memberships => { :user_id => user.id }
      

      #where user is league admin
      can :manage, League, :league_memberships => { :user_id => user.id, :role => LeagueMembership::ROLES[:admin] }
    end
    
  end
end
