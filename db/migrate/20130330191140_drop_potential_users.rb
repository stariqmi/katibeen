class DropPotentialUsers < ActiveRecord::Migration
  def up
    drop_table :potential_users
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
