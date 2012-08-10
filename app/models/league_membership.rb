class LeagueMembership < ActiveRecord::Base
  belongs_to :user
  belongs_to :league
  attr_accessible :balance, :name, :role
end
