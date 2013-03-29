class AddStatusToOutgoingDayPrayer < ActiveRecord::Migration
  def change
    add_column :outgoing_day_prayers, :status, :string
  end
end
