class AddMaxBetToLeagues < ActiveRecord::Migration
  def change
    add_column :leagues, :max_bet, :decimal, :scale => 2, :precision => 12
  end
end
