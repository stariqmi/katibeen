class AddIndexTo < ActiveRecord::Migration
  def up
  	add_index :users, :email, unique: true
  	add_index :potential_users, :email, unique: true
  end

  def down
  end
end
