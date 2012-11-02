class League < ActiveRecord::Base
  POOL_MULTIPLIER = 10

  acts_as_commentable

  attr_accessible :name, :priv, :max_bet, :initial_balance

  belongs_to :user #the league creator
  has_many :questions
  has_many :memberships
  has_many :bets
  has_many :users, :through => :memberships
  has_many :admins, :through => :memberships, 
                    :source => :user, 
                    :conditions => { :memberships => {:role => Membership::ROLES[:admin]} }


  validates :name, :presence => true, :length => { :in => 3..250 }
  validates :user_id, :presence => true
  validates :max_bet, :numericality => { :greater_than_or_equal_to => 1, :less_than_or_equal_to => 1000000 } # $1 to $1 mil
  validates :initial_balance, :numericality => { :greater_than_or_equal_to => 1, :less_than_or_equal_to => 100000 } # $1 to $100k

  after_create :give_creator_admin_membership

private

  def give_creator_admin_membership
    lm = Membership.new
    lm.user = self.user
    lm.role = Membership::ROLES[:admin]
    memberships << lm
  end
  
end
