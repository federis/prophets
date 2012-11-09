class RemoveLeagueIdFromBets < ActiveRecord::Migration
  def up
    remove_column :bets, :league_id
  end

  def down
    add_column :bets, :league_id, :integer
  end
end
