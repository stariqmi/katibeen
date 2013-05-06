class ApplicationController < ActionController::Base
	include SessionsHelper

	protect_from_forgery

  	def session_exists
	    if signed_in?
			@user = current_user
		else
			redirect_to new_user_path
	  	end
	end
	
end
