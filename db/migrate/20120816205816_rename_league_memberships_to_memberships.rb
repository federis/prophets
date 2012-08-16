class RenameLeagueMembershipsToMemberships < ActiveRecord::Migration
  def change
    rename_table :league_memberships, :memberships
  end
end
