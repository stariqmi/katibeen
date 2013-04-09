task :welcomeOdd => :environment do

	users = User.where(registered: false)

	users.each do |user|
		if user.id % 2 == 0
			puts "Hi"
		else
			user.sendRelaunch
		end
	end

end