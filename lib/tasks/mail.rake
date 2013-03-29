task :salat_mail => :environment do
	users = User.all

	users.each do |user|

		#Trace the Time Zone for debug purposes
		puts Time.now.in_time_zone(user.timezone).strftime("%H") == "22"
		puts Time.now.in_time_zone(user.timezone).strftime("%H")

		#Check to see if it is 10pm, send email if it is 10pm => 22 (24 hour clock)
			if Time.now.in_time_zone(user.timezone).strftime("%H") == "22"
				puts user.email
				UserMailer.daily_check_email(user).deliver
				user.day = user.day + 1
				user.save!
			end
		end

end