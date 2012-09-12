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

  def can?(action, object, league = nil)
    a = if league
      Ability.new(self, league)
    elsif defined?(object.league)
      Ability.new(self, object.league)
    else 
      ability
    end
    a.can?(action, object)
  end

  def cannot?(action, object)
    !can?(action, object)
  end

  def self.from_facebook(fb, source)
    user = where(:fb_uid => fb[:uid]).first_or_initialize
    user.fb_uid = fb[:uid]

    if source == :mobile
      user.fb_token = fb[:fb_token]
      user.fb_token_expires_at = Time.at(fb[:fb_token_expires_at])
    elsif source == :omniauth
      user.fb_token = fb[:credentials][:token]
      user.fb_token_expires_at = Time.at(fb[:credentials][:expires_at])
    end

    user.save
    user
  end 

  def self.new_with_session(params, session)
    if session["devise.user_attributes"]
      new(session["devise.user_attributes"], without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end
  end

private
  
  def ability
    @ability ||= Ability.new(self)
  end
  
end
