class UsersController < ApplicationController
include UrlKeyGeneratorHelper
	
	
	# Deals with the post request to the /katibeen/signup url
	def signup

		email = params[:email] # Extract the email from the params of the signup form
		timezone = params[:timezone] # Extract the timezone from the params of the signup form

		@url = uniqueUrlKeyGenerator # Generate a unique url key
		old_user = User.find_by_email(email)

		# If user exists
		if !old_user.nil?
		  # If user is not registered
		  if !old_user.registered?
		    # Send welcome email again and save him
		    old_user.sendWelcomeEmail
		    old_user.save
		  end
		end

		# Find the user in the user db with the same email as extracted in the params
		check_users = User.find_by_email(email)

		#create a new PotentialUser object with the extarcted email, timezone and url key
		user = User.new(email: email, url: @url, timezone: timezone, day: 1, registered: false)

		# If no such user exists
		if check_users.nil?

		#If the new user is valid and can be saved
		  if user.save
		    user.sendWelcomeEmail
		    @title = "Thank you for signing up"
		    @result = "A confirmation email with instructions has been sent to you"
		    @result2 = "Your unique access key is: " + @url

		#If not valid
		  else
		   #Set @result as the error message
		   @title = "Looks like something went wrong ..."
		   @result = "Email #{user.errors[:email][0]}.".html_safe
		  end

		#User by this email already exists
		else

		  if !check_users.registered?
			  # Result instance variable for the view
			  @title = "Looks like something went wrong ..."
			  @result = "User by this email already exists, but we sent another confirmation email just in case"
			  else
			  @title = "Looks like something went wrong ..."
			  @result = "User by this email already exists"
		  end

	end

		# Respond to only javascript, set for AJAX
		respond_to do |format|
			format.js
		end
	end
	
	#Unsubscribe
	def unsubscribe
		url = params[:url] # Extract the url key from the parameters
		@user = User.find_by_url(url)

		if @user == nil
		  redirect_to :controller => "katibeen", :action => "home" # Redirect to the home page

		# If such a user exists
		elsif @user.registered?
		  @user.sendUnsubscribe
		  @user.registered = false
		  @user.save!
		end
	end

	def welcome

    require 'chronic'
	    
	    url = params[:url] # Extract the url key from the parameters
	    @user = User.find_by_url(url)
	    @url = url

	    @modul_title = ""
	    # If no such user exists
	    if @user == nil
	      redirect_to :controller => "katibeen", :action => "home" # Redirect to the home page

	    # If such a @user exists
	    else

	      time = Time.now.in_time_zone(@user.timezone).strftime("%H")
	      time = time.to_i
	      data = OutgoingDayPrayer.where(:url => params[:url])
	      if data[0].nil?

	        if time >= 22
	          @today = true
	          #Creates prayer data based on today since 10PM has passed
	          today = Time.now.in_time_zone(@user.timezone)
	          yesterday = Chronic.parse('yesterday')
	          @dayData_prev = OutgoingDayPrayer.create(url: @user.url, weekday: yesterday.strftime("%A"), user_id: @user_id, status: "pending", average: 0)

	          @dayData = OutgoingDayPrayer.create(url: @user.url, weekday: today.strftime("%A"),
	                                              user_id: @user.id, status: "pending", average: 0)
	          @prayer_day_id = @dayData.id
	          @prayer_day_id_prev = @dayData_prev.id
	          @last_form_title = "(today - #{today.strftime('%B, %d')})"
	          @modul_title = "(yesterday - #{yesterday.strftime('%B, %d')})"
	        else
	          #If it is less than 10PM we use yesterday for the prayer data
	          #Chronic.now = Time.now.in_time_zone(@user.timezone)
	          date = Chronic.parse('yesterday')
	          day_bfr_yesterday = date.advance(:days => -1)
	          weekday = date.strftime("%A")
	          day_bfr_yesterday_weekday = day_bfr_yesterday.strftime("%A")
	          @dayData_prev = OutgoingDayPrayer.create(url: @user.url, weekday: day_bfr_yesterday_weekday,
	                                              user_id: @user.id, status: "pending", average: 0)
	          @dayData = OutgoingDayPrayer.create(url: @user.url, weekday: weekday,
	                                              user_id: @user.id, status: "pending", average: 0)
	          @prayer_day_id = @dayData.id
	          @prayer_day_id_prev = @dayData_prev.id
	          @last_form_title = "(#{date.strftime('%B, %d')})"
	          @modul_title = "(#{day_bfr_yesterday.strftime('%B, %d')})"
	        end

	      else
	        @dayData = data[1]
	        @prayer_day_id = @dayData.id
	        @dayData_prev = data[0]
	        @modul_title = "on #{@dayData_prev.created_at.strftime('%B, %d')}"
	        @last_form_title = "(#{@dayData.created_at.strftime('%B, %d')})"
	        @prayer_day_id_prev = @dayData_prev.id
	      end

	    end
	end

end
