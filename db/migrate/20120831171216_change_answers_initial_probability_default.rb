class ChangeAnswersInitialProbabilityDefault < ActiveRecord::Migration
  def up
    change_column_default(:answers, :initial_probability, 0)
  end

  def down
    change_column_default(:answers, :initial_probability, nil)
  end
end
