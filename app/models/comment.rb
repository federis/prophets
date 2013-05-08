class Comment < ActiveRecord::Base
  attr_accessible :comment, :title

  include ActsAsCommentable::Comment

  belongs_to :commentable, :polymorphic => true, :counter_cache => true
  belongs_to :user

  default_scope :order => 'created_at DESC'
  
  validates :comment, :presence => true, :length => { :in => 1..250 }
  validates :user_id, :presence => true
  validates :commentable_id, :presence => true
  validates :commentable_type, :presence => true, :inclusion => { :in => ["League", "Question", "Bet"] }

  after_create :enqueue_notifications_jobs
  after_create :increment_comments_count_for_activity
  before_destroy :decrement_comments_count_for_activity

private

  def enqueue_notifications_jobs
    Resque.enqueue(SendNotificationsForNewCommentJob, self.id)
  end

  def increment_comments_count_for_activity
    activity_id = Activity.where(feedable_type: commentable_type, feedable_id: commentable_id).pluck(:id).first
    Activity.increment_counter(:comments_count, activity_id) if activity_id
  end

  def decrement_comments_count_for_activity
    activity_id = Activity.where(feedable_type: commentable_type, feedable_id: commentable_id).pluck(:id).first
    Activity.decrement_counter(:comments_count, activity_id) if activity_id
  end

end
