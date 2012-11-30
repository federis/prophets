object @league
attributes :id, :user_id, :name, :priv, :max_bet, :initial_balance, :memberships_count, :questions_count, :comments_count, :created_at, :updated_at

child :tags do
  attributes :id, :name
end