class AddWantsQuestionCreatedNotificationsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :wants_question_created_notifications, :boolean, default: true
  end
end
