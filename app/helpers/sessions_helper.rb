module SessionsHelper
	def sign_in(user)
    	cookies[:katibean_token] = user.remember_token
    	self.current_user = user
  	end
  	
  	def current_user=(user)
    	@current_user = user
  	end

  	def current_user
    	@current_user ||= Premium.find_by_remember_token(cookies[:katibean_token])
  	end
  	
  	def signed_in?
    	!self.current_user.nil?
  	end
end