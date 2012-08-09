class CreateLeagues < ActiveRecord::Migration
  def change
    create_table :leagues do |t|
      t.string :name
      t.boolean :priv, :default => false
      t.references :user

      t.timestamps
    end
    add_index :leagues, :user_id
  end
end
