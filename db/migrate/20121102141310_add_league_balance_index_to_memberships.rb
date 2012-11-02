class AddLeagueBalanceIndexToMemberships < ActiveRecord::Migration
  def change
    add_index :memberships, [:league_id, :balance]
  end
end
