class UpdateIndexForLeagueActivities < ActiveRecord::Migration
  def change
    remove_index :activities, :league_id
    add_index :activities, [:league_id, :created_at]
  end
end
