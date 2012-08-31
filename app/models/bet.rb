class Bet < ActiveRecord::Base
  belongs_to :answer
  belongs_to :user
  attr_accessible :amount, :answer_id

  validates :user_id, :presence => true
  validates :answer_id, :presence => true
  validates :amount, :numericality => { :greater_than_or_equal_to => 0, :less_than_or_equal_to => :league_max_bet }
  validates :probability, :numericality => { :greater_than_or_equal_to => 0, :less_than_or_equal_to => 1 }
  validates :bonus, :numericality => { :greater_than_or_equal_to => 1, :less_than_or_equal_to => 2 }, 
                    :unless => Proc.new{|b| b.bonus.nil? }

  before_validation :set_probability_to_answer_current, :on => :create

  after_create :increment_answer_bet_total!

  def league_max_bet
    answer.question.league.max_bet
  end

private

  def set_probability_to_answer_current
    self.probability = answer.current_probability
  end

  def increment_answer_bet_total!
    answer.bet_total += amount 
    answer.save
  end

end
