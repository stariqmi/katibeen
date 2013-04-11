ActionMailer::Base.smtp_settings = {
  :address              => "smtp.mandrillapp.com",
  :port                 => 587,
  :domain 							=> 'katibean.com',
	:enable_starttls_auto => true,
	:user_name            => "salah@katibean.com",
	:password             => ENV["MANDRILL"],
	:authentication 			=> 'login',
}

ActionMailer::Base.delivery_method = :smtp

ActionMailer::Base.default_url_options[:host] = "katibean-next.herokuapp.com"