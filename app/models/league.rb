class League < ActiveRecord::Base
  belongs_to :creator, :foreign_key => "user_id", :class_name => "User"
  attr_accessible :name, :private
end
