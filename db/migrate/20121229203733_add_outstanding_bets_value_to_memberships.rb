class AddOutstandingBetsValueToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :outstanding_bets_value, :decimal, :scale => 2, :precision => 12, :default => 0
    add_index :memberships, [:outstanding_bets_value, :league_id]
  end
end
