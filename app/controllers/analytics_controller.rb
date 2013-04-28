class AnalyticsController < ApplicationController

#Helper Code ----------------------- START ------------------------------------
include UrlKeyGeneratorHelper # To generate a unique url key
# include TimeZoneManager
include UserPerformanceDataHelper # To generate missed prayers data for a user
#Helper Code ------------------------ END ----------------------------------


  def get

  	require 'chronic'

  	users = User.where(:registered => true)
  	missed = 0

  	averages = []
  	fajrs = []
  	zuhrs = []
  	asrs = []
  	maghribs = []
  	ishas = []

  	active_users = []

  	users.each do |user|
  		begin
			performance = PerformanceData.new user # New PerformanceData object
			average = Float(performance.userAvgCalculator)
			prayersData = performance.prayersData

			@filteredData = {
		            missedPrayerData: prayersData[:missedPrayersData],
		            weeklyPerformedAvgData: prayersData[:weeklyPerformedAvgData],
		            avgWeekdayData: prayersData[:weekdayAvgPrayersData]
				}
			def is_active?(user)
				data = OutgoingDayPrayer.where(["created_at >= ? AND created_at <= ?", Chronic.parse('4 days ago'), Chronic.parse('3 days ago')])
				data = data.where(:url => user.url, :status => "pending")
				if data[0]
					return true
				else
					return false
				end
			end
			if is_active?(user)
				active_users.push(user)
			end
			missed = missed + @filteredData[:missedPrayerData][:totalMissed]

			fajr = @filteredData[:weeklyPerformedAvgData][:fajr]
			zuhr = @filteredData[:weeklyPerformedAvgData][:zuhr]
			asr = @filteredData[:weeklyPerformedAvgData][:asr]
			maghrib = @filteredData[:weeklyPerformedAvgData][:maghrib]
			isha = @filteredData[:weeklyPerformedAvgData][:isha]

			fajrs.push(fajr)
			zuhrs.push(zuhr)
			asrs.push(asr)
			maghribs.push(maghrib)
			ishas.push(isha)

			averages.push(average)

        rescue Exception => e
        	puts e
        end
    end


    @average = 0.0
    averages.each do |a|
    	@average = @average + a
    end
    @average = @average/averages.count

    @fajr = 0.0
    fajrs.each do |a|
    	@fajr = @fajr + a
    end
    @fajr = @fajr/fajrs.count

    @zuhr = 0.0
    zuhrs.each do |a|
    	@zuhr = @zuhr + a
    end
    @zuhr = @zuhr/zuhrs.count

    @asr = 0.0
    asrs.each do |a|
    	@asr = @asr + a
    end
    @asr = @asr/asrs.count

    @maghrib = 0.0
    maghribs.each do |a|
    	@maghrib = @maghrib + a
    end
    @maghrib = @maghrib/maghribs.count

    @isha = 0.0
    ishas.each do |a|
    	@isha = @isha + a
    end
    @isha = @isha/ishas.count

    @total_prayers = OutgoingDayPrayer.where(:status => "responded").count
    @total_missed = missed
    @total_prayed = @total_prayers - @total_missed

    @total_users = User.all.count
    @registered = User.where(:registered => true).count
    @active = active_users.count
    @last_week = User.where(["created_at >= ?", Chronic.parse('last week')]).count
    @last_month = User.where(["created_at >= ? AND created_at <= ?", Chronic.parse('last month'), Chronic.parse('last week')]).count
  end
end
