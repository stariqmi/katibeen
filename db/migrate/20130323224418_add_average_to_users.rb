class AddAverageToUsers < ActiveRecord::Migration
  def up
    add_column :users, :average, :float
  end
  def down
  	remove_column :users, :average, :float
  end
end
