task :farhan => :environment do
	require 'chronic'
	user = User.find_by_email("mehuzi@gmail.com")
	i = 1
		day = "tomorrow"
		day = Chronic.parse(day)
			puts "Message Sent to: " + user.email
			dayData = OutgoingDayPrayer.create(url: user.url, weekday: day.strftime("%A"), user_id: user.id, status: "pending", average: 0)
			UserMailer.daily_check_email(user, dayData).deliver
			user.save!
	while i < 6
		day = i + " days from now"
		day = Chronic.parse(day)
		dayData = OutgoingDayPrayer.create(url: user.url, weekday: day.strftime("%A"), user_id: user.id, status: "pending", average: 0)
		UserMailer.daily_check_email(user, dayData).deliver
		user.save!
		i = i + 1
	end

end