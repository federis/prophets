class AddCounterCacheColumns < ActiveRecord::Migration
  def up
    add_column :leagues, :comments_count, :integer, :default => 0
    add_column :leagues, :questions_count, :integer, :default => 0
    add_column :leagues, :memberships_count, :integer, :default => 0
    add_column :questions, :comments_count, :integer, :default => 0
    add_column :answers, :bets_count, :integer, :default => 0

    League.all.each{|l| 
      League.reset_counters(l.id, :comments)
      League.reset_counters(l.id, :questions)
      League.reset_counters(l.id, :memberships)
    }

    Question.all.each{|q| Question.reset_counters(q.id, :comments)}
    Answer.all.each{|a| Answer.reset_counters(a.id, :bets)}
  end

  def down
    remove_column :leagues, :comments_count
    remove_column :leagues, :questions_count
    remove_column :leagues, :memberships_count
    remove_column :questions, :comments_count
    remove_column :answers, :bets_count
  end
end