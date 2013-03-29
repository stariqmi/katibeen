class DropIncomingDayPrayerTable < ActiveRecord::Migration
  def up
    drop_table :incoming_day_prayers
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
