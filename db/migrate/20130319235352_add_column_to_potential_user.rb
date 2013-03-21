class AddColumnToPotentialUser < ActiveRecord::Migration
  def up
    add_column :potential_users, :url, :string
  end

  def down
  	add_column :potential_users, :url, :string
  end
end
