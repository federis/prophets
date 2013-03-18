object @league
attributes :id, :user_id, :name, :priv, :max_bet, :initial_balance, :memberships_count, :questions_count, :comments_count, :created_at, :updated_at
node(:creator_name){|l| l.user.name }

child :tags do
  extends "tags/show"
end

child(:memberships){ extends "memberships/show" } if @include_memberships