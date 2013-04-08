task :test => :environment do

	users = User.all
	users.each do |user|
		if user.registered?
			puts "Message Sent to: " + user.email
			dayData = OutgoingDayPrayer.create(url: user.url, weekday: Time.now.in_time_zone(user.timezone).strftime("%A"), user_id: user.id, status: "pending", average: 0)
			UserMailer.daily_check_email(user, dayData).deliver
			user.save!
		end
	end

end