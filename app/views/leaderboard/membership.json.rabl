attributes :id, :user_id, :league_id, :balance, :outstanding_bets_value, :created_at, :updated_at
node(:leaderboard_rank){|m| m.leaderboard_rank.to_i }
node(:user_name){|m| m.user.name }