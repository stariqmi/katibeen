class UsersController < ApplicationController
#Helper Code ----------------------- START ------------------------------------
include UrlKeyGeneratorHelper # To generate a unique url key
# include TimeZoneManager

	def new
		@user = User.new
	end

	def create
		puts params[:user][:email]
		@url = uniqueUrlKeyGenerator
		@user = User.new(email: params[:user][:email], url: @url, timezone: params[:timezone])
		puts @user.email

    if @user.save!
      redirect_to root_path
    else

     redirect_to root_path
    end
	end

end
