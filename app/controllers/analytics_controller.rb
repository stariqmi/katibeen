class AnalyticsController < ApplicationController
http_basic_authenticate_with :name => "katibean", :password => "What'sup!"

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

  	data = OutgoingDayPrayer.where(:status => "responded")
  	data.each do |d|
  		begin
			fajr = d.fajr/2
			zuhr = d.zuhr/2
			asr = d.asr/2
			maghrib = d.maghrib/2
			isha = d.isha/2

			fajrs.push(fajr)
			zuhrs.push(zuhr)
			asrs.push(asr)
			maghribs.push(maghrib)
			ishas.push(isha)

			average = Float((Int(fajr) + Int(zuhr) + Int(asr) + Int(magrhib) + Int(isha))/5)

			averages.push(average)
			puts average
        rescue Exception => e
        	puts e
        end
    end

  	users.each do |user|
  		begin
			performance = PerformanceData.new user # New PerformanceData object
			prayersData = performance.prayersData
			missed = missed + prayersData[:missedPrayersData][:totalMissed]
        rescue Exception => e
        	puts e
        end
    end


    @average = 0.0
    averages.each do |a|
    	@average = @average + a
    end
    @average = @average/averages.count 
    @average = @average.round(2)

    @fajr = 0.0
    fajrs.each do |a|
    	@fajr = @fajr + a
    end
    @fajr = (@fajr/fajrs.count) * 100
    @fajr = @fajr.round(2)

    @zuhr = 0.0
    zuhrs.each do |a|
    	@zuhr = @zuhr + a
    end
    @zuhr = (@zuhr/zuhrs.count) * 100
    @zuhr = @zuhr.round(2)

    @asr = 0.0
    asrs.each do |a|
    	@asr = @asr + a
    end
    @asr = (@asr/asrs.count) * 100
    @asr = @asr.round(2)

    @maghrib = 0.0
    maghribs.each do |a|
    	@maghrib = @maghrib + a
    end
    @maghrib = (@maghrib/maghribs.count) * 100
    @maghrib = @maghrib.round(2)

    @isha = 0.0
    ishas.each do |a|
    	@isha = @isha + a
    end
    @isha = (@isha/ishas.count) * 100
    @isha = @isha.round(2)

    @total_prayers = OutgoingDayPrayer.where(:status => "responded").count * 5
    @total_missed = missed
    @total_prayed = @total_prayers - @total_missed

    @total_users = User.all.count
    @registered = User.where(:registered => true).count

    @active = OutgoingDayPrayer.where(["created_at >= ? AND created_at <= ?", Chronic.parse('4 days ago'), Chronic.parse('3 days ago')]).where(:status => "responded").count 

    @last_week = User.where(["created_at >= ?", Chronic.parse('last week')]).count
    @last_month = User.where(["created_at >= ?", Chronic.parse('last month')]).count
  end
end
