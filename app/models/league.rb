class League < ActiveRecord::Base
  attr_accessible :name, :priv

  belongs_to :user #the league creator
  has_many :questions
  has_many :memberships
  has_many :users, :through => :memberships
  has_many :admins, :through => :memberships, 
                    :source => :user, 
                    :conditions => { :memberships => {:role => Membership::ROLES[:admin]} }

  validates :name, :presence => true
  validates :user_id, :presence => true

  after_create :give_creator_admin_membership

private

  def give_creator_admin_membership
    lm = Membership.new
    lm.user = self.user
    lm.role = Membership::ROLES[:admin]
    memberships << lm
  end
  
end
