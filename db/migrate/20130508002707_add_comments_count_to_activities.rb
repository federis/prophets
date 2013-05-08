class AddCommentsCountToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :comments_count, :integer, default: 0
  end
end
