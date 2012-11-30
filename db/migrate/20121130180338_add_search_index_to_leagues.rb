class AddSearchIndexToLeagues < ActiveRecord::Migration
  def up
    execute "create index leagues_name on leagues using gin(to_tsvector('english', name))"
  end

  def down
    execute "drop index leagues_name"
  end
end
