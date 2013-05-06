class AddPasswordToUsers < ActiveRecord::Migration
  def change
    add_column :users, :password, :string
    add_column :users, :premium, :boolean
  end
end
