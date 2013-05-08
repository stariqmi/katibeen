class SessionsController < ApplicationController

include SessionsHelper

  def new
   if signed_in?
    redirect_to '/signup'
   end
  end

  def create
    user = Premium.find_by_email(params[:session][:email].downcase)
    if user.nil? 
      user = Premium.find_by_username(params[:session][:email])
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
    session[:user_id] = nil
    redirect_to '/signup'
  end

end