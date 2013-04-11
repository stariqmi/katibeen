require 'time_diff'

module UserPerformanceDataHelper

	class PerformanceData
		# Instance variables accessible outside the class
		attr_accessor :user, :rawData, :weeks, :average

		# Initializer for the class
		def initialize user

			# Set the class user variable as the model user
			@user = user

			# Extract all the prayer data, i.e those salah
			# checks to which people have responded or has expired
			@rawData = OutgoingDayPrayer.where("url = ? AND status = ? OR status = ?", @user.url, "responded", "deactivated")

			# Count the number of times the salah check email has
			# been responded to or expired. Represents the data for dashboard.
			@timesRequestSent = @rawData.count

			# Convert days to weeks
			@weeks = (@timesRequestSent / 7.0)

		end

		# Calculates the data for display on the dashboard.
		def prayersData
			totalMissed = 0				# Initial value of totalMissed missed prayers
			totalPerformed = 0			# Initial value of totalPerformed completed prayers
			mostMissed = ""				# Initial value of type of most missed prayer

			# Initial hashes of prayer types and the number missed/performed for each type
			missedData = 	{ fajr: 0, zuhr: 0, asr: 0, maghrib: 0, isha: 0 }
			performedData = { fajr: 0, zuhr: 0, asr: 0, maghrib: 0, isha: 0 }
			# Initial hash for weekday data, count represents the # of times a
			# particular weekday has passed.
			weekdayData = 	{
							  	"Monday"		=>	{ count: 0, prayerCount: 0 },
							  	"Tuesday"		=>	{ count: 0, prayerCount: 0 },
							  	"Wednesday" 	=>	{ count: 0, prayerCount: 0 },
						 	  	"Thursday" 		=> 	{ count: 0, prayerCount: 0 },
							  	"Friday" 		=> 	{ count: 0, prayerCount: 0 },
							  	"Saturday" 		=>	{ count: 0, prayerCount: 0 },
							  	"Sunday" 		=>	{ count: 0, prayerCount: 0 }

							}


			# Loop through the rawData instance variable
			@rawData.each do |day|
				# Extract the weekday of the "day"
				weekday = day[:weekday]
				# Add one to the "count" fot that particular weekday in the weeldayData
				weekdayData[weekday][:count] += 1

				# Update fajr and totalMissed count
				# Extract the fajr data
				fajr_data = day[:fajr]

				# If fajr is not offered
				if fajr_data == 0
					# Add one to missed fajr prayer
					missedData[:fajr]  += 1
					# Add one to total missed prayer
					totalMissed += 1

				# If fajr is offered
				elsif fajr_data == 2
					# Add one to performed fajr prayer
					performedData[:fajr] +=1
					# Add one to total performed prayers
					totalPerformed += 1
					# Add one to performed prayer for the weekday
					weekdayData[weekday][:prayerCount] += 1

				# Case for QAZA
				else
					nil
				end


				# Update zuhr and totalMissed count 			(Remaining inside comments are the same as above)
				# Extract the zuhr data
				zuhr_data = day[:zuhr]

				if zuhr_data == 0
					 missedData[:zuhr] += 1
					 totalMissed += 1
				elsif zuhr_data == 2
					performedData[:zuhr] +=1
					totalPerformed += 1
					weekdayData[weekday][:prayerCount] += 1
				else
					nil
				end


				# Update asr and totalMissed count 				(Remaining inside comments are the same as above)
				asr_data = day[:asr]

				if asr_data == 0
					missedData[:asr] += 1
					totalMissed += 1
				elsif asr_data == 2
					performedData[:asr] +=1
					totalPerformed += 1
					weekdayData[weekday][:prayerCount] += 1
				else
					nil
				end


				# Update maghrib and totalMissed count 			(Remaining inside comments are the same as above)
				maghrib_data = day[:maghrib]

				if maghrib_data == 0
					missedData[:maghrib] += 1
					totalMissed += 1
				elsif maghrib_data == 2
					performedData[:maghrib] +=1
					totalPerformed += 1
					weekdayData[weekday][:prayerCount] += 1
				else
					nil
				end


				# Update isha and totalMissed count 			(Remaining inside comments are the same as above)
				isha_data = day[:isha]

				if isha_data == 0
					missedData[:isha] += 1
					totalMissed += 1
				elsif isha_data == 2
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
					# Update 'mostMissed' variable as key
					mostMissed = key
					# Update the 'initial' value as value
					initial  = value
				else
					nil
				end
			end

			# Add the totalMissed and mostMissed data to the hash
			missedData[:totalMissed] = totalMissed
			missedData[:mostMissed] = mostMissed.to_s.capitalize

			# Loop through the performed prayer data to convert to weekly prayer average for each prayer type
			performedData.each do |key, value|
				# Calculate the average value in terms of decimals
				avg = value/@timesRequestSent.to_f
				# Convert the average to percentage
				avg = (avg.round(2) * 100).to_i
				# Update the value of the key as the average calculated
				performedData[key] = avg
			end

			# Convert weekdayData to averages
			# Use the weekdayAvgCalculator  defined below
			weekdayData = weekdayAvgCalculator weekdayData
			# Sort the hash into an array
			weekdayData = weekdayData.sort_by {|key, value| value}
			# Extract the length of the sorted array
			length = weekdayData.count
			# Push in ["worst", weekday], where the value is the first key, value pair in the sorted array
			weekdayData << ["worst", weekdayData[0][0]]
			# Push in ["best", weekday], where the value is the last key, value pair in the sorted array
			weekdayData << ["best", weekdayData[length - 1][0]]

			# Convert the above sorted array into a hash
			avgWeekdayData = {}
			# Loop through the weekday data
			weekdayData.each do |data|
				# Set the key, value pair as the data[0], data[1]
				avgWeekdayData[data[0]] = data[1]
			end

			# Arrange the above 3 hashes in a single hash
			data = { missedPrayersData: missedData, weeklyPerformedAvgData: performedData, weekdayAvgPrayersData: avgWeekdayData }
		end

		# Converts a nested hash into a non-nested hash, used to convert the
		# nested hash of weekdayData
		def weekdayAvgCalculator data
			data.each do |key, value|
				if value[:count] == 0
					data[key] = 0
				else
					avg = (value[:prayerCount] / value[:count].to_f).round(2)
					data[key] = avg
				end
			end
		end


		# Calculates the average of a user
		def userAvgCalculator
			total = 0									# Initial total prayers
			# Loop through each all the Day prayers
			@rawData.each do |day|
				total += 1 if day[:fajr] == 2			# Add one to total if prayer performed
				total += 1 if day[:zuhr] == 2			# Add one to total if prayer performed
				total += 1 if day[:asr] == 2			# Add one to total if prayer performed
				total += 1 if day[:maghrib] == 2		# Add one to total if prayer performed
				total += 1 if day[:isha] == 2			# Add one to total if prayer performed
			end
			# Calculate how many days the user was requested for a response,
			# and the user responded and or the email was deactivated
			avg = (total / @timesRequestSent.to_f).round(2) # Calculate the average
		end

		# Check if a day if "perfect", i.e all 5 prayers were performed
		def perfectDayChecker day
			# If all five prayers were performed
			if day[:fajr] == 2 && day[:zuhr] == 2 && day[:asr] == 2 && day[:maghrib] == 2 && day[:isha] == 2
			 	true 	# Return true
			else
				false	# Return false
			end
		end

		# Find the longest streak, using the above perfectDayChecker helper function
		def longestStreak
			# Set an initial value for the streak
			streak = 0
			# Set an empty array to hold the streak values
			streakArray = []
			# Loop through the raw data
			@rawData.each do |day|
				# Check if a day is "prefect"
				if perfectDayChecker day
					streak += 1 							# Add one to the previous streak value
				# If the day is not prefect
				else
					streakArray << streak if streak > 0		# If the previous streak count was not zero
															# That means that there were consecutive perfect days
															# Push the value of the streak in the array
					streak = 0								# Reset the streak
				end
			end
			# Push in the last value of the streak since the loop ends before adding it.
			streakArray << streak
			streakArray.max 								# Return the max value in the array
		end

		# Calculates the data for the main Dot chart
		def mainWidgetData
			# Set an empty array
			data = []
			# Loop through the rawData
			@rawData.each do |day|
				# Set the empty array for each day
				dayHash = []
				dayHash << [day[:total_prayed], "total"]	# Push in the key value pair [value, "total"]
				dayHash << [day[:fajr], "fajr"]				# Push in the key value pair [value, "fajr"]
				dayHash << [day[:zuhr], "duhr"]				# Same as above
				dayHash << [day[:asr], "asr"]				# Same as above
				dayHash << [day[:maghrib], "maghrib"]		# Same as above
				dayHash << [day[:isha], "isha"]				# Same as above
				data <<	dayHash								# Push in the dayHash into the main parent hash
			end
			# Generate a path for the dot chart svg
			# Set the initial value of the path
			path = "M10 20 "
			# Loop through the entire data
			(0..(@timesRequestSent-1)).each do |i|
				# Add path based on the average per day prayer, using the "total" value
				path += "L#{30+ 60*i} #{20 - (data[i][0][0]/5.to_f)*20} "
			end
			# End path
			path += "L#{60*@timesRequestSent - 10} 20 Z"
			# Return both the path and the day array
			{ data: data, path: path }
		end

		def lineGraphData
			

			#  !!!!!!!!!!!!  NEW CALCULATION !!!!!!!!!!!!!!!!!
			total_prayed_array = []
			@rawData.each do |row|
				total = (row[:fajr] + row[:zuhr] + row[:asr] + row[:maghrib] + row[:isha]) / 2
				total_prayed_array << total
			end 			

			average_array = []
			divisor = 1
			total_tracker = 0
			total_prayed_array.each do |t|
				total_tracker += t
				average = total_tracker / divisor.to_f
				average_array << average.round(2)
				divisor += 1
			end

			puts "$$$$$$$$$$$$$$$$$$$$$$$$$$"
			puts average_array.inspect
			puts "$$$$$$$$$$$$$$$$$$$$$$$$$$"
			# !!!!!!!!!!!!!!!!!!!!!!! NEW CALCULATION ENDS !!!!!!!!!!!!!!
			


			# Set intial values for path calculation
			lowest = 5
			highest = 0
			start_height = 0		# Height for the initial prayer average
			end_height = 0			# Height for the final prayer average
			start_avg = 0
			end_avg = 0

			# If less than 15 days have passed
			if @timesRequestSent < 15
				horizon_distance = 750 / (@timesRequestSent - 1)
				average_array.each do |data|
					# Update the lowest
					lowest = data if data < lowest
					# Update the highest
					highest = data if data > highest
				end
				# Calculate the difference between the lowest, highest
				high_low_diff = highest - lowest

				# If the highest and the lowest
				if highest == lowest
					d = "M0 #{150 - (lowest/5.to_f)*150} L950 #{150 - (lowest/5.to_f)*150} L950 #{150 - (lowest/5.to_f)*150 + 5} L0 #{150 - (lowest/5.to_f)*150 + 5} Z"
					start_height = 150 - (lowest/5.to_f)*150
					end_height = 150 - (lowest/5.to_f)*150
					start_avg = lowest
					end_avg = lowest

				else
					# Calculate the unit height for each unit of average
					unit = (150 / high_low_diff.to_f).round(2)
					#Set the starting height using the first average
					d = "M0 #{150 - (average_array[0] - lowest)*unit} "

					# Loop  through the rest of the data.
					(1..(@timesRequestSent-1)).each do |i|
						# Update the path of the svg, move to the right and set the height depending on the distance
						# from  lowest
						d += "L#{horizon_distance*i} #{150 - (average_array[i] - lowest)*unit} "
					end

					# Apply the same process as above with the reverse of the hash, and an increased height of 5
					@data = Hash[average_array.to_a.reverse]
					(1..(@timesRequestSent - 1)).each do |i|
						d += "L#{horizon_distance*(@timesRequestSent - i)} #{150 - (average_array[(@timesRequestSent-i)] - lowest)*unit + 5} "
					end
					d += "L0 #{150 - (average_array[0] - lowest)*unit + 5} Z"

					# Set the start height, end height, start avg and end avg
					start_height = 150 - ((average_array[0]- lowest)*unit).round(1)
					end_height = 150 - ((average_array[@timesRequestSent - 1] - lowest)*unit).round(1)
					start_avg = average_array[0]
					end_avg = average_array[@timesRequestSent-1]
				end

			# If more than 15 days have passed
			else
				# Extarct the lastest 15 days
				# The remaining process is the same as for the previous less tahn 15 days condition
				requiredData = average_array[@timesRequestSent - 16, @timesRequestSent]
				horizon_distance = (750 / 15.to_f).round(2)
				requiredData.each do |data|
					lowest = data if data < lowest
					highest = data if data > highest
				end
				high_low_diff = highest - lowest
				unit = (150 / high_low_diff.to_f).round(2)
				d = "M0 #{150 - (requiredData[0] - lowest)*unit} "
				(1..14).each do |i|
					d += "L#{horizon_distance*i} #{150 - (requiredData[i] - lowest)*unit} "
				end
				@data = Hash[requiredData.to_a.reverse]
				(1..14).each do |i|
					d += "L#{horizon_distance*(15 - i)} #{150 - (requiredData[(15-i)] - lowest)*unit + 5} "
				end
				d += "L0 #{150 - (requiredData[0] - lowest)*unit + 5} Z"
				start_height = 150 - (requiredData[0] - lowest)*unit
				end_height = 150 - (requiredData[14] - lowest)*unit
				start_avg = @rawData[@timesRequestSent - 16]
				end_avg = requiredData[14]
			end

			# Data for the extreme cases when the height is less than 1
			start_height = 1 if start_height < 1
			end_height = 1 if end_height < 1

			# Calculate the improvement for the last 15 days
			if start_avg == 0
				improvement = (end_avg/1)*100
			else
				improvement = ((end_avg - start_avg) / start_avg).round(2) * 100
			end

			# Return all the extracted data
			{lineGraphPath: d, startHeight: start_height, endHeight: end_height, startAvg: start_avg, endAvg: end_avg, improvement: improvement}
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
