class AddPublishBetsToFbToUsers < ActiveRecord::Migration
  def change
    add_column :users, :publish_bets_to_fb, :boolean, default: false
  end
end
