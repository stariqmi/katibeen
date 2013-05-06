class CreatePremia < ActiveRecord::Migration
  def change
    create_table :premia do |t|
      t.string :password
      t.string :email
      t.string :username
      t.string :remember_token

      t.timestamps
    end
  end
end
