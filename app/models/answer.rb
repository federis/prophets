class Answer < ActiveRecord::Base
  belongs_to :question
  belongs_to :user
  belongs_to :judge, :class_name => "User"
  has_many :bets

  attr_accessible :content, :question_id, :initial_probability

  validates :content, :presence => true, :length => { :in => 1..250 }
  validates :question_id, :presence => true
  validates :user_id, :presence => true
  validates :judge_id, :presence => true, :if => Proc.new{|a| !a.judged_at.nil? }
  validates :initial_probability, :numericality => { :greater_than_or_equal_to => 0, :less_than_or_equal_to => 1 }
  validates :current_probability, :numericality => { :greater_than_or_equal_to => 0, :less_than_or_equal_to => 1 }

  before_validation :set_current_probability_to_intial, :on => :create

  def total_pool_share
    bet_total + initial_probability * question.initial_pool
  end

  def judge!(is_correct, judging_user)
    raise ArgumentError, "Correct must be true or false. #{is_correct.inspect} given." unless is_correct == true || is_correct == false
    raise CanCan::AccessDenied unless judging_user.can? :judge, self, question.league

    self.correct = is_correct
    self.judged_at = Time.now
    self.judge = judging_user

    Answer.delay.process_bets_for_judged_answer(self.id, is_correct)

    if is_correct #if this is the correct answer, the others are implicitly incorrect
      question.answers.each do |a|
        a.judge!(false, judging_user) unless a == self
      end
    end

    save!
  end

  ["current", "initial"].each do |type|
    class_eval <<-RUBY, __FILE__, __LINE__ + 1
      def #{type}_probability
        self[:#{type}_probability].nil? ? nil : self[:#{type}_probability].round(Answer.#{type}_probability_scale)
      end

      def self.#{type}_probability_scale
        @#{type}_probability_scale ||= columns.find {|r| r.name == '#{type}_probability'}.scale
      end
    RUBY
  end

  def pay_bettors!
    bets.each do |bet|
      bet.pay_bettor!
    end
  end

  def zero_bet_payouts!
    bets.each do |bet|
      bet.zero_payout!
    end
  end

  def self.process_bets_for_judged_answer(id, is_correct)
    answer = find(id)
    if is_correct
      answer.pay_bettors!
    else
      answer.zero_bet_payouts!
    end
  end

private

  def set_current_probability_to_intial
    self.current_probability = self.initial_probability
  end

end
