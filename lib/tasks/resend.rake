task :resend => :environment do

	users = User.where(registered: false)

	users.each do |user|
		puts user
		user.sendWelcomeEmail
	end

end