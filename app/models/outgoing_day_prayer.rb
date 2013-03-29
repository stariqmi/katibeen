class OutgoingDayPrayer < ActiveRecord::Base
  attr_accessible :asr, :fajr, :isha, :maghrib, :time, :url, :user_id, :weekday, :zuhr, :status
  belongs_to :user
end
