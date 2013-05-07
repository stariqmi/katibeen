module SessionsHelper
	def sign_in(user)
    	cookies[:katibean_token] = user.remember_token
    	session[:user_id] = user.id
  	end

  	def current_user
    	@current_user ||= Premium.find(session[:user_id]) if session[:user_id]
  	end
  	
  	def signed_in?
      !session[:user_id].nil?
  	end
end