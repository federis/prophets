class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :league
  attr_accessible :name, :user_id

  ROLES = { :admin => 1, :member => 2 }

  validates :role, :presence => :true, :inclusion => { :in => ROLES.values }
  validates :user_id, :presence => :true, :uniqueness => { :scope => :league_id, :message => "is already a member of that league" }
  validates :league_id, :presence => :true
  validates :balance, :numericality => { :greater_than_or_equal_to => 0 }

  scope :admins, where(:role => ROLES[:admin])

  before_validation :set_balance_to_league_initial, :on => :create

  def outstanding_bets_value
    user.bets.outstanding.where(:league_id => league.id).reduce(0){|sum, bet| sum + bet.amount }
  end

private

  def set_balance_to_league_initial
    self.balance = league.initial_balance
  end
  
end
