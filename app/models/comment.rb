class Comment < ActiveRecord::Base
  attr_accessible :comment, :title

  include ActsAsCommentable::Comment

  belongs_to :commentable, :polymorphic => true
  belongs_to :user

  default_scope :order => 'created_at DESC'
  
  validates :comment, :presence => true, :length => { :in => 1..250 }
  validates :user_id, :presence => true
  validates :commentable_id, :presence => true
  validates :commentable_type, :presence => true, :inclusion => { :in => ["League", "Question"] }
end
