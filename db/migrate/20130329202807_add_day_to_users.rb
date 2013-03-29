class AddDayToUsers < ActiveRecord::Migration
  def change
    add_column :users, :day, :int
  end
end
