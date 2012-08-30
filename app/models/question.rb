class Question < ActiveRecord::Base
  belongs_to :league
  belongs_to :user
  belongs_to :approver, :class_name => "User"
  has_many :answers
  
  attr_accessible :content, :desc

  validates :user_id, :presence => true
  validates :league_id, :presence => true
  validates :content, :presence => true, :length => { :in => 10..250 }
  validates :desc, :length => { :in => 0..2000 }
  validates :initial_pool, :numericality => { :greater_than_or_equal_to => 1, :less_than_or_equal_to => 10000000 } # $1 to $10 mil

  scope :approved, where('questions.approved_at IS NOT NULL')
  scope :unapproved, where('questions.approved_at IS NULL')

  before_create :attempt_self_approval
  before_validation :set_initial_pool, :on => :create

  def approved_by=(approving_user)
    if approving_user.can? :approve, self
      self.approver = approving_user
      self.approved_at = Time.now
    end
  end
  
  def approved?
    !approved_at.nil?
  end

private

  def attempt_self_approval
    self.approved_by = user 
  end

  def set_initial_pool
    self.initial_pool = league.max_bet * League::POOL_MULTIPLIER
  end

end
