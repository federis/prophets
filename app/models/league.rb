class League < ActiveRecord::Base
  attr_accessible :name, :priv

  belongs_to :user #the league creator
  has_many :league_memberships
  has_many :users, :through => :league_memberships
  has_many :admins, :through => :league_memberships, 
                    :source => :user, 
                    :conditions => { :league_memberships => {:role => LeagueMembership::ROLES[:admin]} }

  validates :name, :presence => true
  validates :user_id, :presence => true

  after_create :give_creator_admin_membership

private

  def give_creator_admin_membership
    lm = LeagueMembership.new
    lm.user = self.user
    lm.role = LeagueMembership::ROLES[:admin]
    league_memberships << lm
  end
  
end
