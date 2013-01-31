class AddCompletedAtToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :completed_at, :datetime
  end
end
