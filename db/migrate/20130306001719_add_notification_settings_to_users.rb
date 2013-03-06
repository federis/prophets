class AddNotificationSettingsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :wants_notifications, :boolean, default: true
    add_column :users, :wants_new_question_notifications, :boolean, default: true
  end
end
