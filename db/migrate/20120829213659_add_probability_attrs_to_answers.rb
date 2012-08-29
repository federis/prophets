class AddProbabilityAttrsToAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :initial_probability, :decimal, :scale => 5, :precision => 6
    add_column :answers, :current_probability, :decimal, :scale => 5, :precision => 6
    add_column :answers, :correct, :boolean
    add_column :answers, :bet_total, :decimal, :scale => 2, :precision => 15
  end
end
