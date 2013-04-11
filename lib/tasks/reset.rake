task :reset => :environment do

	data = OutgoingDayPrayer.all

	data.each do |data|
		data.destroy
	end

	users = User.where(registered: true)

	users.each do |user|
		user.average = nil
		user.day = 1
		user.registered = false
		user.save
	end

end