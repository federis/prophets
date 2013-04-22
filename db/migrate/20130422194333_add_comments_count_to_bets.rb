class AddCommentsCountToBets < ActiveRecord::Migration
  def change
    add_column :bets, :comments_count, :integer, default: 0
  end
end
