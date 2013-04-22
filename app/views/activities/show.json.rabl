object @activity
attributes :id, :content, :league_id, :feedable_id, :feedable_type, :created_at, :updated_at

node(:comments_count){|activity| activity.feedable.try(:comments_count) }