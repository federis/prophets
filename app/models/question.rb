class Question < ActiveRecord::Base
  belongs_to :league
  belongs_to :user
  belongs_to :approver, :class_name => "User"
  attr_accessible :approved_at, :content, :desc
end
