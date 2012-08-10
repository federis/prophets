class Ability
  include CanCan::Ability

  def initialize(user)

    unless user.nil?
      can :create, League, :user_id => user.id
    end
    
  end
end
