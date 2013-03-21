class PotentialUserMailer < ActionMailer::Base
  default from: "katibeen.com"

  # To send mail to a potential user upon sign up
  def signup_email(puser)
    @puser = puser # Instance variable passed into the view to be used
    mail(:to => puser.email, :subject => "Welcome to katibeen")
  end
end
