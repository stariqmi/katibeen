class PotentialUserMailer < ActionMailer::Base
  default from: "katibeantest@gmail.com"

  # To send mail to a potential user upon sign up
  def confirmation_email(puser)
    @puser = puser # Instance variable passed into the view to be used
    mail(:to => puser.email, :subject => "Confirm your Account!")
  end
end
