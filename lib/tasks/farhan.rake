task :farhan => :environment do
	require 'chronic'
	user = User.find_by_email("farhanm995@gmail.com")
	i = 1
		day = "tomorrow"
		day = Chronic.parse(day)
			puts "Message Sent to: " + user.email
			dayData = OutgoingDayPrayer.create(url: user.url, weekday: day.strftime("%A"), user_id: user.id, status: "pending", average: 0)
			UserMailer.daily_check_email(user, dayData).deliver
			user.save!

end