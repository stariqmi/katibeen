class AddColumnToPotentialUsers < ActiveRecord::Migration
  def up
    add_column :potential_users, :timezone, :string
  end
  def down
  	remove_column :potential_users, :timezone, :string
  end
end
