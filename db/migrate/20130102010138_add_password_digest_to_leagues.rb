class AddPasswordDigestToLeagues < ActiveRecord::Migration
  def change
    add_column :leagues, :password_digest, :string
  end
end
