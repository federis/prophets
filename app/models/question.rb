class Question < ActiveRecord::Base
  belongs_to :league
  belongs_to :user
  belongs_to :approver, :class_name => "User"
  has_many :answers
  
  attr_accessible :content, :desc

  validates :user_id, :presence => true
  validates :league_id, :presence => true
  validates :content, :presence => true

  scope :approved, where('questions.approved_at IS NOT NULL')
  scope :unapproved, where('questions.approved_at IS NULL')

  before_create :attempt_self_approval!

  def approved_by=(approving_user)
    if approving_user.can? :approve, self
      self.approver = approving_user
      self.approved_at = Time.now
    end
  end

private

  def attempt_self_approval! 
    self.approved_by = user 
  end

end
