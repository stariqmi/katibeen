module UserPerformanceDataHelper
	def rawDataExtractor user
		prayerDays = user.incoming_day_prayers
	end

	def missedPrayerData rawData
		
		missedData = {fajr: 0, zuhr: 0, asr: 0, maghrib: 0, isha: 0}
		rawData.each do |day|
			if day[:fajr] == 0 ? missedData[:fajr] += 1 : nil
			end
			if day[:zuhr] == 0 ? missedData[:zuhr] += 1 : nil
			end
			if day[:asr] == 0 ? missedData[:asr] += 1 : nil
			end
			if day[:maghrib] == 0 ?	missedData[:maghrib] += 1 : nil
			end
			if day[:isha] == 0 ? missedData[:isha] += 1 : nil
			end
		end
		return missedData
	end

	def prayersPerWeekData rawData, joinDate
		
	end


end


# 1) To find the time of user in his/her time zone, use Time.now.in_time_zone(user.timezone), adding .to_date gives only the date.
# 2) Time.now.in_time_zone(user.timezone).strftime("%A") => weekday
# 3) Time.now.in_time_zone(user.timezone).strftime("%H") => hours
# 4) Time.now.in_time_zone(user.timezone).strftime("%M") => minutes
# 5) When sending an email, i.e prayer form, use (2) to extract the weekday for db and (1) to extract the datetime
# 6) When recieving an email, use (1) to get current time in users timezone, and then compare with the datetime field of outgoing data,
#    , if the difference is more than 3 days, then donot transfer to incoming table
# 7) To check for time zone window, if user is between 21:50 - 22:10, send the email, else dont. 
# 8) For calculations in (7), convert to minutes the actual time and the above limits and see if it is in the limit.
