class AddPayoutToBets < ActiveRecord::Migration
  def change
    add_column :bets, :payout, :decimal, :scale => 2, :precision => 15
  end
end
