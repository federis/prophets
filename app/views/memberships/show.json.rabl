object @membership
attributes :id, :user_id, :league_id, :role, :balance, :rank, :outstanding_bets_value, :created_at, :updated_at

if @include_leagues
  child(:league){ extends 'leagues/show' }
end