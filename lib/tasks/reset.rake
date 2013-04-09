task :reset => :environment do

	data = OutgoingDayPrayer.all

	data.each do |data|
		data.destroy
	end

	users = User.where(:re)

end