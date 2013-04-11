task :welcomeEven => :environment do

	users = User.where(registered: false)

	users.each do |user|
		if user.id % 2 == 0
			user.sendRelaunch
		end
	end

end