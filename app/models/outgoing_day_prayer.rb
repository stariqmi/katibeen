class OutgoingDayPrayer < ActiveRecord::Base
  attr_accessible :asr, :fajr, :isha, :maghrib, :time, :url, :user_id, :weekday, :zuhr, :status, :average, :total_prayed, :created_at
  belongs_to :user
end
