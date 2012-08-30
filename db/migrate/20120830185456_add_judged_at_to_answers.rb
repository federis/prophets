class AddJudgedAtToAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :judged_at, :datetime
  end
end
