class AddAverageToOutgoingDayPrayer < ActiveRecord::Migration
  def change
    add_column :outgoing_day_prayers, :average, :float
  end
end
