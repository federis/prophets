class AddIntialBalanceToLeagues < ActiveRecord::Migration
  def change
    add_column :leagues, :initial_balance, :decimal, :scale => 2, :precision => 12
  end
end
