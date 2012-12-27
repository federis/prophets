class League < ActiveRecord::Base
  POOL_MULTIPLIER = 10

  acts_as_commentable
  acts_as_taggable

  include PgSearch
  pg_search_scope :search_by_name, :against => :name

  attr_accessible :name, :priv, :max_bet, :initial_balance, :tag_list

  belongs_to :user #the league creator
  has_many :questions
  has_many :memberships
  has_many :bets
  has_many :users, :through => :memberships
  has_many :admins, :through => :memberships, 
                    :source => :user, 
                    :conditions => { :memberships => {:role => Membership::ROLES[:admin]} }

  scope :visible_to, lambda{|user| includes(:memberships).where(["memberships.user_id = ? OR leagues.priv = ?", user.id, false]) }

  validates :name, :presence => true, :length => { :in => 3..250 }
  validates :user_id, :presence => true
  validates :max_bet, :numericality => { :greater_than_or_equal_to => 1, :less_than_or_equal_to => 1000000 } # $1 to $1 mil
  validates :initial_balance, :numericality => { :greater_than_or_equal_to => 1, :less_than_or_equal_to => 100000 } # $1 to $100k

  validate :ensure_tag_list_only_uses_existing_tags

  after_create :give_creator_admin_membership

  before_validation :set_default_values, :on => :create

private

  def set_default_values
    self.max_bet ||= 100000 #100k
    self.initial_balance ||= 10000 #10k
  end

  def give_creator_admin_membership
    lm = Membership.new
    lm.user = self.user
    lm.role = Membership::ROLES[:admin]
    memberships << lm
  end

  def ensure_tag_list_only_uses_existing_tags
    conditions = self.tag_list.map { |tag| "lower(name) = ?" }.join(" OR ")
    tag_names = self.tag_list.map{|tag| tag.to_s.downcase }
    existing_tags_count = ActsAsTaggableOn::Tag.where([conditions, *tag_names]).count
    errors[:base] << "One of the categories does not exist" unless existing_tags_count == self.tag_list.count
  end
  
end
