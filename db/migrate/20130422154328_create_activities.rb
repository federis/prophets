class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.references :feedable, :polymorphic => true
      t.references :league
      t.integer :activity_type
      t.string :content

      t.timestamps
    end

    add_index :activities, :league_id
    add_index :activities, [:feedable_id, :feedable_type]
  end
end
