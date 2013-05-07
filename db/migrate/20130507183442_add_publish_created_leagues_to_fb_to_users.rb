class AddPublishCreatedLeaguesToFbToUsers < ActiveRecord::Migration
  def change
    add_column :users, :publish_created_leagues_to_fb, :boolean, default: false
  end
end
