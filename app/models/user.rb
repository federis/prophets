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

  before_save :ensure_authentication_token

  def membership_in_league(league)
    memberships.where(:league_id => league.id).first
  end
end
