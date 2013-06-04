class AddWantsJudgementNotificationsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :wants_judgement_notifications, :boolean, default: true
  end
end
