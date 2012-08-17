class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :league
  attr_accessible :name, :user_id

  ROLES = {
    :admin => 1,
    :member => 2
  }

  validates :role, :presence => :true
  validates :user_id, :presence => :true, :uniqueness => { :scope => :league_id, :message => "is already a member of that league" }
  validates :league_id, :presence => :true

  scope :admins, where(:role => ROLES[:admin])
  
end
