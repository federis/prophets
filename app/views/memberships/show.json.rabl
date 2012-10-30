object @membership
attributes :id, :user_id, :league_id, :role, :balance, :created_at, :updated_at

if @include_leagues
  child(:league){ extends 'leagues/show' }
end