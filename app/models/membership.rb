class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :league, :counter_cache => true
  has_many :bets

  attr_accessible :name
  attr_accessible :name, :user_id, :role, :as => :admin

  ROLES = { :admin => 1, :member => 2 }

  validates :role, :presence => :true, :inclusion => { :in => ROLES.values }
  validates :user_id, :presence => :true, :uniqueness => { :scope => :league_id, :message => "is already a member of that league" }
  validates :league_id, :presence => :true
  validates :balance, :numericality => { :greater_than_or_equal_to => 0 }

  scope :admins, where(:role => ROLES[:admin])

  before_validation :set_balance_to_league_initial, :on => :create

  def rank
    @rank ||= league.memberships.where(["memberships.balance + memberships.outstanding_bets_value > ?", balance + outstanding_bets_value]).count + 1
  end

  def admin?
    role == ROLES[:admin]
  end

  def user_name
    user.name
  end

  ["balance", "outstanding_bets_value"].each do |type|
    class_eval <<-RUBY, __FILE__, __LINE__ + 1
      def #{type}
        self[:#{type}].nil? ? nil : self[:#{type}].round(Membership.#{type}_scale)
      end

      def self.#{type}_scale
        @#{type}_scale ||= columns.find {|r| r.name == '#{type}'}.scale
      end
    RUBY
  end

private

  def set_balance_to_league_initial
    self.balance = league.initial_balance
  end
  
end
