class AddTimesUpdatedToOutgoingDayPrayer < ActiveRecord::Migration
  def change
    add_column :outgoing_day_prayers, :times_updated, :integer
  end
end
