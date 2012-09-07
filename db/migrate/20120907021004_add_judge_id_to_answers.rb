class AddJudgeIdToAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :judge_id, :integer
  end
end
