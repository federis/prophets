object @activity
attributes :id, :content, :feedable_id, :feedable_type, :created_at, :updated_at

node(:comments_count){|activity| activity.feedable.try(:comments_count) }