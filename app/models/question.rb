class Question < ActiveRecord::Base
  belongs_to :league
  belongs_to :user
  belongs_to :approver, :class_name => "User"
  attr_accessible :content, :desc

  validates :user_id, :presence => true
  validates :league_id, :presence => true
  validates :content, :presence => true

  scope :approved, where('questions.approved_at IS NOT NULL')

  before_save :approve_if_created_by_admin

private

  def approve_if_created_by_admin 
    if user.can? :approve, self
      self.approver = user
      self.approved_at = Time.now
    end
  end

end
