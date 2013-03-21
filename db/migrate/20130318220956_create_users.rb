class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :url
      t.string :timezone

      t.timestamps
    end
  end
end
