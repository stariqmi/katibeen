class CreateIncomingDayPrayers < ActiveRecord::Migration
  def change
    create_table :incoming_day_prayers do |t|
      t.string :url
      t.datetime :time
      t.string :weekday
      t.integer :fajr
      t.integer :zuhr
      t.integer :asr
      t.integer :maghrib
      t.integer :isha
      t.integer :user_id

      t.timestamps
    end
  end
end
