class SessionsController < ApplicationController

  def new
  	@session = Session.new
   if signed_in?
    redirect_to '/'
   end
  end

  def create
    user = Premium.find_by_email(params[:session][:email].downcase)
    if user.nil? 
      user = Premium.find_by_name(params[:session][:email])
    end
    if user && user.authenticate(params[:session][:password])
      sign_in user
      redirect_to '/'
    else
      flash.now[:error] = 'Invalid email/password combination' 
      render 'new'
    end
  end

  def destroy
    self.current_user = nil
    puts '----------------------------------'
    puts self.current_user
    cookies.delete(:katibean_token)
    redirect_to '/'
  end
end