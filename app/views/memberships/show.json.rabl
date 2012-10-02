object @membership
attributes :id, :user_id, :role, :balance, :created_at, :updated_at

if @include_leagues
  child(:league){ extends 'leagues/show' }
else
  attributes :league_id
end