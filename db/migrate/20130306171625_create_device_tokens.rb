class CreateDeviceTokens < ActiveRecord::Migration
  def change
    create_table :device_tokens do |t|
      t.references :user
      t.string :value

      t.timestamps
    end
    add_index :device_tokens, :user_id
    add_index :device_tokens, :value
  end
end
