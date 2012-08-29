class CreateBets < ActiveRecord::Migration
  def change
    create_table :bets do |t|
      t.references :user
      t.references :answer
      t.decimal :amount, :scale => 2, :precision => 12
      t.decimal :probability, :scale => 5, :precision => 6
      t.decimal :bonus, :scale => 5, :precision => 7

      t.timestamps
    end
    add_index :bets, :user_id
    add_index :bets, :answer_id
  end
end
