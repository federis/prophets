class ChangeUserIdToMembershipIdInBets < ActiveRecord::Migration
  def up
    add_column :bets, :membership_id, :integer
    remove_column :bets, :user_id
  end

  def down
    add_column :bets, :user_id
    remove_column :membership_id
  end
end
