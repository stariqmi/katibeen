class AddTotalPrayedToOutgoingDayPrayer < ActiveRecord::Migration
  def change
    add_column :outgoing_day_prayers, :total_prayed, :integer
  end
end
