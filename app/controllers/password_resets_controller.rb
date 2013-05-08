class PasswordResetsController < ApplicationController

	def new

	end

	def index
	end

	def create
  		premium = Premium.find_by_email(params[:email])
  		premium.send_password_reset if premium
  		redirect_to root_url, :notice => "Email sent with password reset instructions."
	end

	def edit
	  @premium = Premium.find_by_password_reset_token!(params[:id])
	end

	def update
	  @premium = Premium.find_by_password_reset_token!(params[:id])
	  if @premium.password_reset_sent_at < 2.hours.ago
	    redirect_to new_password_reset_path, :alert => "Password reset has expired."
	  elsif @premium.update_attributes(params[:premium])
	    redirect_to root_url, :notice => "Password has been reset!"
	  else
	    render :edit
	  end
	end

end