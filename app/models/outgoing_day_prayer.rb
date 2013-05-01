class OutgoingDayPrayer < ActiveRecord::Base
  attr_accessible :asr, :fajr, :isha, :maghrib, :time, :url, :user_id, :weekday, :zuhr, :status, :average, :total_prayed, :created_at, :updated_at
  belongs_to :user

  def get_average 
  	average = self.asr + self.fajr + self. maghrib + self.isha + self.zuhr 
  	average = average/2
  	return average
  end
end
