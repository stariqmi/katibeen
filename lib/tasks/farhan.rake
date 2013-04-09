task :farhan => :environment do
	require 'chronic'
	user = User.find_by_email("mehuzi@gmail.com")
	i = 5
	while i < 8
		day = i.to_s + " days from now"
		day = Chronic.parse(day)
		dayData = OutgoingDayPrayer.create(url: user.url, weekday: day.strftime("%A"), user_id: user.id, status: "pending", average: 0)
		UserMailer.daily_check_email(user, dayData).deliver
		user.save!
		i = i + 1
	end

end