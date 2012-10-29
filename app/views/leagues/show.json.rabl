object @league
attributes :id, :user_id, :name, :priv, :max_bet, :initial_balance, :created_at, :updated_at
node(:memberships_count){ |league| league.memberships.count }
node(:questions_count){ |league| league.questions.count }