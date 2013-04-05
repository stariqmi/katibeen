task :clear => :environment do
	users = User.where(registered: false)
	puts users

	users.each do |user|

		puts !user.created_at < 5.days.ago

		prayers = OutgoingDayPrayer.where(:url => user.url)
		puts prayers
		if prayers.nil?

			puts  user.created_at > 5.days.ago
			if !user.created_at > 5.days.ago
				user.destroy
			end
		end
	end

end