class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :league
  attr_accessible :name

  ROLES = {
    :admin => 1,
    :member => 2
  }

  validate :role, :presence => :true

  scope :admins, where(:role => ROLES[:admin])
  
end
