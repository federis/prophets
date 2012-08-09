class League < ActiveRecord::Base
  belongs_to :creator, :foreign_key => "user_id", :class_name => "User"
  attr_accessible :name, :priv

  validates :name, :presence => true
  validates :user_id, :presence => true
  
end
