class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name

  has_many :created_leagues, :class_name => "League"
  has_many :memberships
  has_many :leagues, :through => :memberships
  has_many :bets

  before_save :ensure_authentication_token

  def membership_in_league(league)
    memberships.where(:league_id => league.id).first
  end

  def is_admin_of_league?(league)
    memberships.where(:league_id => league.id, :role => Membership::ROLES[:admin]).count > 0
  end

  def is_member_of_league?(league)
    memberships.where(:league_id => league.id).count > 0
  end

  def can?(action, object)
    a = defined?(object.league) ? Ability.new(self, object.league) : ability
    a.can?(action, object)
  end

  def cannot?(action, object)
    !can?(action, object)
  end

private
  
  def ability
    @ability ||= Ability.new(self)
  end
  
end
