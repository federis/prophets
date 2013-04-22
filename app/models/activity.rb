class Activity < ActiveRecord::Base

  TYPES = {
    :bet_created => 1,
    :bet_payout => 2,
    :question_published => 3
  }

  attr_accessible :content, :feedable_id, :feedable_type, :activity_type
  belongs_to :feedable, polymorphic: true
  belongs_to :league

  validates :activity_type, inclusion: { in: TYPES.values }
end
