module SessionsHelper
	def sign_in(premium)
    	session[:premium_id] = premium.id
  	end

  	def current_user
    	@current_user ||= Premium.find(session[:premium_id]) if session[:premium_id]
  	end
  	
  	def signed_in?
      !session[:premium_id].nil?
  	end
end