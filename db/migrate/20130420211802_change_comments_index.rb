class ChangeCommentsIndex < ActiveRecord::Migration
  def change
    remove_index :comments, :commentable_id
    remove_index :comments, :commentable_type
    add_index :comments, [:commentable_type, :commentable_id]
  end
end
