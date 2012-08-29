class AddInitialPoolToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :initial_pool, :decimal, :scale => 2, :precision => 15
  end
end