class PremiumMailer < ActionMailer::Base
  default from: "salah@katibean.com"

	def password_reset(premium)
		@premium = premium
		mail :to => premium.email, :subject => "Password Reset"
	end

end