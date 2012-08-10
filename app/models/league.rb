class League < ActiveRecord::Base
  belongs_to :user #the league creator
  attr_accessible :name, :priv

  validates :name, :presence => true
  validates :user_id, :presence => true
  
end
