class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :content
      t.text :desc
      t.references :league
      t.references :user
      t.integer :approver_id
      t.timestamp :approved_at

      t.timestamps
    end
    add_index :questions, :league_id
    add_index :questions, :user_id
    add_index :questions, :approver_id
  end
end
