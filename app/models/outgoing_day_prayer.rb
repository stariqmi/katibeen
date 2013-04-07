class OutgoingDayPrayer < ActiveRecord::Base
  attr_accessible :asr, :fajr, :isha, :maghrib, :time, :url, :user_id, :weekday, :zuhr, :status, :average, :total_prayed, :created_at, :updated_at
  belongs_to :user

  def check_welcome_entry
  	time = self.updated_at
  	year = time.strftime("%Y").to_i
  	month = time.strftime("%m").to_i
  	day = time.strftime("%d").to_i
  	hour = time.strftime("%H").to_i
  	minutes = time.strftime("%M").to_i
  end
end
