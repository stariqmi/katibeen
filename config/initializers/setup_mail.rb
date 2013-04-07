ActionMailer::Base.smtp_settings = {
  :address              => "smtp.mandrillapp.com",
  :port                 => 587,
	:enable_starttls_auto => true, # detects and uses STARTTLS
	:user_name            => "farhanm995@gmail.com",
	:password             => 'hqsZnuQmNHKqJSyaAuS2aw',
	:domain 							=> 'gmail.com', # your domain to identify your server when connecting
	:authentication 			=> 'login', # Mandrill supports 'plain' or 'login'
}

ActionMailer::Base.default_url_options[:host] = "localhost:3000"