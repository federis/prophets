class AddFbUidIndexToUsers < ActiveRecord::Migration
  def change
    add_index :users, :fb_uid, :unique => true
  end
end
