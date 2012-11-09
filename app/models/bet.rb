class Bet < ActiveRecord::Base
  belongs_to :answer
  belongs_to :membership
  attr_accessible :amount

  validates :answer_id, :presence => true
  validates :amount, :numericality => { :greater_than_or_equal_to => 0, :less_than_or_equal_to => :league_max_bet }
  validates :probability, :numericality => { :greater_than => 0, :less_than => 1 }
  validates :bonus, :numericality => { :greater_than_or_equal_to => 1, :less_than_or_equal_to => 2 }, 
                    :unless => Proc.new{|b| b.bonus.nil? }

  validate :ensure_user_has_necessary_funds, :on => :create
  validate :ensure_betting_is_open, :on => :create
  validate :ensure_answer_and_membership_in_same_league

  before_validation :set_probability_to_answer_current, :on => :create

  after_create :increment_answer_bet_total!
  after_create :update_question_answer_probabilities!
  after_create :decrement_user_balance_by_bet_amount!

  after_destroy :decrement_answer_bet_total!
  after_destroy :refund_bet_to_user!

  scope :made_after, lambda{|after_date| where("created_at > ?", after_date)}
  scope :outstanding, where(:payout => nil)

  def league_max_bet
    #possibly should be membership.league instead
    answer.question.league.max_bet
  end

  def judged?
    !payout.nil?
  end

  def invalidated?
    !invalidated_at.nil?
  end

  def invalidate!
    self.invalidated_at = Time.now
    Bet.transaction do
      decrement_answer_bet_total!
      refund_bet_to_user!
      save!
    end
  end

  def probability
    self[:probability].nil? ? nil : self[:probability].round(Bet.probability_scale)
  end

  def self.probability_scale
    @probability_scale ||= columns.find {|r| r.name == 'probability'}.scale
  end

  def payout_when_correct
    amount + amount * (1/probability - 1)
  end

  def pay_bettor!
    self.payout = payout_when_correct
    if membership # in case they left the league
      membership.balance += payout
      Bet.transaction do
        membership.save!
        save!
      end
    end
  end

  def zero_payout!
    self.payout = 0
    save!
  end

private

  def set_probability_to_answer_current
    self.probability = answer.current_probability
  end

  def increment_answer_bet_total!
    answer.bet_total += amount 
    answer.save!
  end

  def decrement_answer_bet_total!
    answer.bet_total -= amount 
    answer.save!
  end

  def decrement_user_balance_by_bet_amount!
    membership.balance -= amount
    membership.save!
  end

  def update_question_answer_probabilities!
    answer.question.update_answer_probabilities!
  end

  def refund_bet_to_user!
    membership.balance += amount
    membership.save!
  end

  def ensure_user_has_necessary_funds 
    errors[:base] << errors.generate_message(:base, :insufficient_funds_to_cover_bet) unless membership.balance >= amount
  end
  
  def ensure_betting_is_open
    errors[:base] << errors.generate_message(:base, :betting_has_been_closed) unless answer.open_for_betting?
  end

  def ensure_answer_and_membership_in_same_league
    errors[:base] << errors.generate_message(:base, :answer_and_membership_same_league) unless membership.league_id == answer.question.league_id
  end

end
