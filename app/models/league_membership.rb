class LeagueMembership < ActiveRecord::Base
  belongs_to :user
  belongs_to :league
  attr_accessible :name

  ROLES = {
    :admin => 1,
    :member => 2
  }

  validate :role, :presence => :true

  before_save :ensure_role

  scope :admins, where(:role => ROLES[:admin])

  def ensure_role
    self.role ||= ROLES[:member]
  end
  
end
