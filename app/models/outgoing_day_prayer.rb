class OutgoingDayPrayer < ActiveRecord::Base
  attr_accessible :asr, :fajr, :isha, :maghrib, :time, :url, :user_id, :weekday, :zuhr, 
                  :status, :average, :total_prayed, :created_at, :updated_at
  belongs_to :user

  def get_average 
  	average = self.asr + self.fajr + self. maghrib + self.isha + self.zuhr 
  	average = average/2
  	average
  end

  def get_date 
  	date = self.created_at
  	date_end = 'st'
  	if date.strftime("%e").to_s[-1] == '1'
  		date_end = 'st'
  	elsif date.strftime("%e").to_s[-1] == '2'
  		date_end = 'nd'
  	elsif date.strftime("%e").to_s[-1] == '3'
  		date_end = 'rd'
  	else 
  		date_end = 'th'
  	end
  	date = date.strftime("%B").to_s + ' ' + date.strftime("%e").to_s + date_end + ' ' + date.strftime("%Y").to_s

  	date
  end

end
