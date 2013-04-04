ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => "katibean.com",
  :user_name            => "salah@katibean.com",
  :password             => ENV["PASSWORD"],
  :authentication       => "plain",
  :enable_starttls_auto => true
}

ActionMailer::Base.default_url_options[:host] = "katibean.com"