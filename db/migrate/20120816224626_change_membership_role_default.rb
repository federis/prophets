class ChangeMembershipRoleDefault < ActiveRecord::Migration
  def up
    change_column_default(:memberships, :role, 2)
  end

  def down
    change_column_default(:memberships, :role, nil)
  end
end
