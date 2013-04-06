task :error => :environment do

	users = User.all

	users.each do |user|
		puts user.email
		UserMailer.error(user).deliver
	end

end