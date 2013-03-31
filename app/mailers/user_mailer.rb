class UserMailer < ActionMailer::Base
  default from: "katibeantest@gmail.com"

  # To send mail to a potential user upon sign up
  def confirmation_email(puser)
    @puser = puser # Instance variable passed into the view to be used
    mail(:to => puser.email, :subject => "Confirm your Account")
  end

  def daily_check_email(user, dayData)
  	@user = user
    @dayData = dayData
  	mail(:to => user.email, :subject => "Salat Check: " + Time.now.in_time_zone(user.timezone).to_s)
  end
end