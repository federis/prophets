class Bet < ActiveRecord::Base
  belongs_to :answer
  attr_accessible :amount, :bonus, :probability

  validates :user_id, :presence => true
  validates :answer_id, :presence => true
  validates :amount, :presence => true
end
