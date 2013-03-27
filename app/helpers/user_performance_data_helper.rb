require 'time_diff'

module UserPerformanceDataHelper
	
	class PerformanceData
		# Instance variables accessible outside the class
		attr_accessor :user, :rawData, :weeks, :average
		
		# Initializer for the class
		def initialize user
			@user = user 											# Set the class user variable as the model user
			@rawData = user.incoming_day_prayers					# Extract all the prayer data
			@timesRequestSent = user.outgoing_day_prayers.count
			@weeks = (@timesRequestSent / 7.0) 					# Convert days to weeks, rounding to 10 decimal places
		end


		# Creates a hash of the # of missed prayer of each type, totalMissed 
		# missed prayers and the type missed the most 
		def prayersData
			totalMissed = 0				# Initial value of totalMissed missed prayers
			totalPerformed = 0			# Initial value of totalPerformed completed prayers					
			mostMissed = ""				# Initial value of type of most missed prayer
			# Initial hashes of prayer types and the number missed/performed for each type
			missedData = 	{ fajr: 0, zuhr: 0, asr: 0, maghrib: 0, isha: 0 }
			performedData = { fajr: 0, zuhr: 0, asr: 0, maghrib: 0, isha: 0 }
			# Initial hash for weekday, th
			weekdayData = 	{ "Monday"		=>	{ count: 0, prayerCount: 0 },
							  "Tuesday"		=>	{ count: 0, prayerCount: 0 },
							  "Wednesday" 	=>	{ count: 0, prayerCount: 0 },
						 	  "Thursday" 	=> 	{ count: 0, prayerCount: 0 },
							  "Friday" 		=> 	{ count: 0, prayerCount: 0 },
							  "Saturday" 	=>	{ count: 0, prayerCount: 0 },
							  "Sunday" 		=>	{ count: 0, prayerCount: 0 }
							}


			# Loop through the rawData instance variable
			@rawData.each do |day|
				weekday = day[:weekday]							# Extract the weekday
				weekdayData[weekday][:count] += 1 				# Update the weekday count

				# Update fajr and totalMissed count
				if day[:fajr] == 0 
					missedData[:fajr]  += 1 					# Add one to missed fajr prayer
					totalMissed += 1 							# Add one to total missed prayer
				elsif day[:fajr] == 2
					performedData[:fajr] +=1 					# Add one to performed fajr prayer
					totalPerformed += 1 						# Add one to total performed prayers
					weekdayData[weekday][:prayerCount] += 1		# Add one to performed prayer for the weekday			
				else
					nil
				end


				# Update zuhr and totalMissed count 			(Remaining inside comments are the same as above)
				if day[:zuhr] == 0 
					 missedData[:zuhr] += 1
					 totalMissed += 1
				elsif day[:zuhr] == 2
					performedData[:zuhr] +=1
					totalPerformed += 1
					weekdayData[weekday][:prayerCount] += 1 
				else
					nil
				end


				# Update asr and totalMissed count 				(Remaining inside comments are the same as above)
				if day[:asr] == 0 
					missedData[:asr] += 1
					totalMissed += 1
				elsif day[:asr] == 2
					performedData[:asr] +=1
					totalPerformed += 1
					weekdayData[weekday][:prayerCount] += 1
				else
					nil
				end


				# Update maghrib and totalMissed count 			(Remaining inside comments are the same as above)
				if day[:maghrib] == 0
					missedData[:maghrib] += 1
					totalMissed += 1
				elsif day[:maghrib] == 2
					performedData[:maghrib] +=1
					totalPerformed += 1
					weekdayData[weekday][:prayerCount] += 1
				else
					nil
				end


				# Update isha and totalMissed count 			(Remaining inside comments are the same as above)
				if day[:isha] == 0
					missedData[:isha] += 1
					totalMissed += 1 
				elsif day[:isha] == 2
					performedData[:isha] +=1
					totalPerformed += 1
					weekdayData[weekday][:prayerCount] += 1
				else
					nil
				end
			end


			# Initial variable to keep track of most missed prayer type
			initial = 0
			# Loop through the missedData
			missedData.each do |key, value|
				# If the value is higher than the 'initial'
				if value > initial 
					mostMissed = key		# Update 'mostMissed' variable as key
					initial  = value		# Update the 'initial' value as value
				else
					nil
				end
			end

			# Add the totalMissed and mostMissed data to the hash
			missedData[:totalMissed] = totalMissed
			missedData[:mostMissed] = mostMissed.to_s.capitalize
			
			# Loop through the performed prayer data to convert to weekly prayer average for each prayer type
			performedData.each do |key, value|
				avg = value / @weeks

				#puts "#{value} / #{@weeks} = #{avg}"
				if avg > 7
					performedData[key] = 7
				else
					performedData[key] = avg.round(2)
				end
			end

			# Convert weekdayData to averages
			
			weekdayData = weekdayAvgCalculator weekdayData
			# Sort the hash into an array
			weekdayData = weekdayData.sort_by {|key, value| value}
			length = weekdayData.count 								# Extract the length of the sorted array
			weekdayData << ["worst", weekdayData[0][0]]				# Push in ["worst", weekday]
			weekdayData << ["best", weekdayData[length - 1][0]]		# Push in ["best", weekday]

			avgWeekdayData = {}
			weekdayData.each do |data|
				avgWeekdayData[data[0]] = data[1]
			end

			# Arrange the above 3 hashes in a single hash
			data = { missedPrayersData: missedData, weeklyPerformedAvgData: performedData, weekdayAvgPrayersData: avgWeekdayData }
		end

		# Converts a nested hash into a non-nested hash
		def weekdayAvgCalculator data
			data.each do |key, value|
				avg = (value[:prayerCount] / value[:count].to_f).round(2)	# Sets the value of the hash as a division of the nested hash fields
				if avg.nan? ? data[key] = 0 : data[key] = avg
				end
			end
		end


		# Calculates the average of a user
		def userAvgCalculator
			total = 0											# Initial total prayers
			# Loop through each all the Day prayers											
			rawData.each do |day|
				total += 1 if day[:fajr] == 2			# Add one to total if prayer performed
				total += 1 if day[:zuhr] == 2			# Add one to total if prayer performed
				total += 1 if day[:asr] == 2			# Add one to total if prayer performed
				total += 1 if day[:maghrib] == 2		# Add one to total if prayer performed
				total += 1 if day[:isha] == 2			# Add one to total if prayer performed
			end
			# Calculate how many days the user was requested for a response, each response request represents a day
			avg = (total / @timesRequestSent.to_f).round(2) # Calculate the average
		
		end

		def perfectDayChecker day
			if day[:fajr] == 2 && day[:zuhr] == 2 && day[:asr] == 2 && day[:maghrib] == 2 && day[:isha] == 2
			 	true
			else
				false
			end
		end

		def longestStreak
			streak = 0
			streakArray = []
			rawData.each do |day|
				if perfectDayChecker day
					streak += 1 
				else
					if streak > 0  
						streakArray << streak
					else
						nil
					end
					streak = 0
				end
			end
			streakArray << streak
			streakArray.max
		end

		def mainWidgetData
			data = []
			rawData.each do |day|
				dayHash = {
					fajr: 		day[:fajr],
					zuhr: 		day[:zuhr],
					asr: 		day[:asr],
					maghrib: 	day[:maghrib],
					isha: 		day[:isha]
				}
				data <<	dayHash 
			end
			data
		end

	end	# -------------------------------------END OF CLASS -------------------------------------

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
