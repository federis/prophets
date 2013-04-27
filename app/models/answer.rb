class Answer < ActiveRecord::Base
  belongs_to :question
  belongs_to :user
  belongs_to :judge, :class_name => "User"
  has_many :bets, dependent: :destroy

  attr_accessible :content, :initial_probability

  validates :content, :presence => true, :length => { :in => 1..100 }
  validates :question_id, :presence => true
  validates :user_id, :presence => true
  validates :judge_id, :presence => true, :if => Proc.new{|a| !a.judged_at.nil? }
  validates :initial_probability, :numericality => { :greater_than_or_equal_to => 0, :less_than_or_equal_to => 1 }
  validates :current_probability, :numericality => { :greater_than_or_equal_to => 0, :less_than_or_equal_to => 1 }

  before_validation :set_current_probability_to_intial, :on => :create
  after_save :update_question_answer_probabilities!, if: Proc.new{|a| a.bet_total_changed? }

  def open_for_betting?
    !judged? && question.open_for_betting?
  end

  def total_pool_share
    bet_total + initial_probability * question.initial_pool
  end

  def judged?
    !judged_at.nil?
  end

  def judge!(is_correct, judging_user, known_at = nil)
    raise ArgumentError, "Correct must be true or false. #{is_correct.inspect} given." unless is_correct == true || is_correct == false
    raise CanCan::AccessDenied unless judging_user.can? :judge, self, question.league

    self.correct = is_correct
    self.judged_at = Time.now
    self.judge = judging_user
    self.correctness_known_at = known_at

    Resque.enqueue(ProcessBetsForJudgedAnswerJob, self.id, is_correct, known_at)

    if is_correct #if this is the correct answer, the others are implicitly incorrect
      question.answers.each do |a|
        a.judge!(false, judging_user, known_at) unless a == self || a.judged?
      end
    end
    
    if question.answers.all?{|a| a == self || a.judged? } && question.completed_at.blank?
      question.update_attribute :completed_at, self.judged_at
    end

    save!
  end

  def undo_judgement!
    self.correct = nil
    self.judged_at = nil
    self.judge = nil
    self.correctness_known_at = nil

    Resque.enqueue(UndoBetPayoutsForAnswerJob, self.id)
  end

  ["current_probability", "initial_probability", "bet_total"].each do |type|
    class_eval <<-RUBY, __FILE__, __LINE__ + 1
      def #{type}
        self[:#{type}].nil? ? nil : self[:#{type}].round(Answer.#{type}_scale)
      end

      def self.#{type}_scale
        @#{type}_scale ||= columns.find {|r| r.name == '#{type}'}.scale
      end
    RUBY
  end

  def pay_bettors!
    bets.each do |bet|
      bet.pay_bettor! unless bet.complete?
    end
  end

  def zero_bet_payouts!
    bets.each do |bet|
      bet.zero_payout! unless bet.complete?
    end
  end

  def process_bets_for_judgement(is_correct, known_at = nil)
    bets.made_after(known_at).each{|bet| bet.invalidate! } unless known_at.nil?
    is_correct ? pay_bettors! : zero_bet_payouts!
  end

  def undo_bet_judgements!
    bets.each do |bet|
      bet.undo_judgement! rescue nil #in case the membership doesn't have sufficient balance to reinstate the bet
    end
  end

  def update_question_answer_probabilities!
    question.update_answer_probabilities!
  end

private

  def set_current_probability_to_intial
    self.current_probability = self.initial_probability
  end

end
