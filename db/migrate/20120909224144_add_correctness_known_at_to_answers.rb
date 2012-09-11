class AddCorrectnessKnownAtToAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :correctness_known_at, :datetime
  end
end
