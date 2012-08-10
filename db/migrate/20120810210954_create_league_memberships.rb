class CreateLeagueMemberships < ActiveRecord::Migration
  def change
    create_table :league_memberships do |t|
      t.references :user
      t.references :league
      t.string :name
      t.integer :role
      t.decimal :balance, :scale => 2, :precision => 15

      t.timestamps
    end
    
    add_index :league_memberships, :user_id
    add_index :league_memberships, :league_id
  end
end
