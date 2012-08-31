class Answer < ActiveRecord::Base
  belongs_to :question
  belongs_to :user
  has_many :bets

  attr_accessible :content, :question_id, :initial_probability

  validates :content, :presence => true, :length => { :in => 1..250 }
  validates :question_id, :presence => true
  validates :user_id, :presence => true
  validates :initial_probability, :numericality => { :greater_than_or_equal_to => 0, :less_than_or_equal_to => 1 }
  validates :current_probability, :numericality => { :greater_than_or_equal_to => 0, :less_than_or_equal_to => 1 }

  before_validation :set_current_probability_to_intial, :on => :create

  def total_pool_share
    bet_total + initial_probability * question.initial_pool
  end

private

  def set_current_probability_to_intial
    self.current_probability = self.initial_probability
  end

end
