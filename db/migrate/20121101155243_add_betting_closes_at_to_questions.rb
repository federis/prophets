class AddBettingClosesAtToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :betting_closes_at, :datetime
  end
end
