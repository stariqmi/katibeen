task :salat_mail => :environment do
		users = User.all

		users.each do |u|
			UserMailer.daily_check_email(u).deliver
		end

end