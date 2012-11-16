class Question < ActiveRecord::Base
  acts_as_commentable

  attr_accessible :content, :desc, :betting_closes_at, :answers_attributes

  belongs_to :league, :counter_cache => true
  belongs_to :user
  belongs_to :approver, :class_name => "User"
  has_many :answers
  accepts_nested_attributes_for :answers, :allow_destroy => true

  validates :user_id, :presence => true
  validates :league_id, :presence => true
  validates :content, :presence => true, :length => { :in => 10..250 }
  validates :desc, :length => { :in => 0..2000 }
  validates :initial_pool, :numericality => { :greater_than_or_equal_to => 1, :less_than_or_equal_to => 10000000 } # $1 to $10 mil
  validates :answers, :length => { :minimum => 2 }, :if => Proc.new{|q| q.approved? } 
  validates :betting_closes_at, :presence => true

  validate :ensure_betting_closes_in_future
  validate :check_answer_initial_probabilities, :if => Proc.new{|q| q.approved_at_changed? } 

  scope :approved, where('questions.approved_at IS NOT NULL')
  scope :unapproved, where('questions.approved_at IS NULL')

  before_validation :set_initial_pool, :on => :create

  def answers_attributes=(attrs)
    answers.each do |answer|
      attrs << { :id => answer.id, :_destroy => '1' } unless attrs.collect{|an| an[:id] }.include?(answer.id.to_s)
    end

    super #we can do this because of the initializer nested_attributes_setter.rb
  end

  def open_for_betting?
    approved? && betting_closes_at > Time.now
  end

  def bets_count
    @bets_count ||= answers.reduce(0){|sum, answer| sum + answer.bets.count }
  end

  def approve!(approving_user)
    raise CanCan::AccessDenied unless approving_user.can? :approve, self

    self.approver = approving_user
    self.approved_at = Time.now

    save!    
  end
  
  def approved?
    !approved_at.nil?
  end

  def total_pool
    answers.map(&:bet_total).reduce(:+) + initial_pool
  end

  def update_answer_probabilities!
    answers.each do |a|
      a.current_probability = a.total_pool_share / total_pool
      a.save!
    end
  end

private

  def set_initial_pool
    self.initial_pool = league.max_bet * League::POOL_MULTIPLIER
  end

  def check_answer_initial_probabilities
    prob_sum = (answers.map(&:initial_probability).reduce(:+) * 1000).round rescue 0
    errors[:answers] << errors.generate_message(:answers, :invalid_initial_probabilities_sum) if prob_sum != 1000
  end

  def ensure_betting_closes_in_future
    if !betting_closes_at.blank? && betting_closes_at <= Time.now
      errors[:betting_closes_at] << errors.generate_message(:betting_closes_at, :cant_be_in_past) 
    end
  end

end
