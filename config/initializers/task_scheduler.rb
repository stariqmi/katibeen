require 'rufus/scheduler'
scheduler = Rufus::Scheduler.start_new

scheduler.every '1h' do
  users = User.where(registered: true)
	users.each do |user|

	#Check to see if it is 10pm, send email if it is 10pm => 22 (24 hour clock)
		if Time.now.in_time_zone(user.timezone).strftime("%H") == "22"
			puts "Message Sent to: " + user.email
			dayData = OutgoingDayPrayer.create(url: user.url, weekday: Time.now.in_time_zone(user.timezone).strftime("%A"), user_id: user.id, status: "pending", average: 0)
			UserMailer.daily_check_email(user, dayData).deliver
		else
			puts "No message sent to:" + user.email
		end
	end
end