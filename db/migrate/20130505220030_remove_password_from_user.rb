class RemovePasswordFromUser < ActiveRecord::Migration
  def up
    remove_column :users, :password
    remove_column :users, :password_confirmation
    remove_column :users, :remember_token
  end

  def down
    add_column :users, :password, :string
    add_column :users, :password_confirmation, :string
    add_column :users, :remember_token, :string
  end
end