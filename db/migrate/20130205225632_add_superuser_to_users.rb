class AddSuperuserToUsers < ActiveRecord::Migration
  def change
    add_column :users, :superuser, :integer
  end
end
