class AddInvalidatedAtToBets < ActiveRecord::Migration
  def change
    add_column :bets, :invalidated_at, :datetime
  end
end
