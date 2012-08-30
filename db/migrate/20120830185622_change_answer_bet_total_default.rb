class ChangeAnswerBetTotalDefault < ActiveRecord::Migration
  def up
    change_column_default(:answers, :bet_total, 0)
  end

  def down
    change_column_default(:answers, :bet_total, nil)
  end
end
