class League < ActiveRecord::Base
  attr_accessible :name, :priv

  belongs_to :user #the league creator
  has_many :league_memberships
  has_many :leagues, :through => :league_memberships

  validates :name, :presence => true
  validates :user_id, :presence => true
  
end
