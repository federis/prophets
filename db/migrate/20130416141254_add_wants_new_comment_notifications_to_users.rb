class AddWantsNewCommentNotificationsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :wants_new_comment_notifications, :boolean, default: true
  end
end
