class AddFbTokenRefreshedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :fb_token_refreshed_at, :datetime
  end
end
