task :error => :environment do

	users = User.all
	users.each do |user|
		user
	end

end