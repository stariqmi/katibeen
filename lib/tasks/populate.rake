task :populate => :environment do

	(1..10).each do |n|

		user = User.new
		user.email = "test" + n.to_s + "@gmail.com"
		user.url = "test" + n.to_s
		user.timezone = Time.zone
		user.registered = true
		user.days
		user.save

		(1..15).each do |d|
			prayer = OutgoingDayPrayer.new
			prayer.url =  user.url
			prayer.weekday = d.days.from_now.strftime("%A")
			prayer.user_id = user.id
			prayer.status = "pending"
			prayer.fajr = rand(0..1)*2
			prayer.asr = rand(0..1)*2
			prayer.maghrib = rand(0..1)*2
			prayer.isha = rand(0..1)*2
			prayer.zuhr = rand(0..1)*2
			prayer.average = (prayer.fajr + prayer.asr + prayer.maghrib + prayer.isha + prayer.zuhr)/2
			prayer.total_prayed = prayer.average
			prayer.status =  "responded"
			prayer.save
		end



	end

end