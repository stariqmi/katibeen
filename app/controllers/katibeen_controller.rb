# Module to generate unique url.
module UrlKeyGenerator

  # Generates a 5 character long random string
  def urlKeyGenerator
    # Used as a string from which characters are pulled out from random positions
    library = "abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    arr = []  # Empty array
    # Loop of length 5 to pick a random character from "library"
    # Push the character picked out into the empty array
    (1..5).each { arr << library[rand(61)] } 
    return arr.join # Join the array i.e make it a string and return it
  end

  # Checks each generated key for uniqueness and outputs only a unique key
  def uniqueUrlKeyGenerator
    url = urlKeyGenerator  # Generate a url
    # Extract the user in the user db with that url
    checkInUsers = User.find_by_url(url)
    
    # Loop while a user with the generated url exists already in the user db
    while checkInUsers != nil
      url = urlKeyGenerator # Generate a new url
      # Extract a user with the generated url in the user db
      checkInUsers = User.find_by_url(url)
    end

    # Extract the potential_user in the potential_user db with that url
    checkInPotentialUsers = PotentialUser.find_by_url(url)

    # Loop while a potential_user with the generated url exists already in the potential_user db
    while checkInPotentialUsers != nil
      url = urlKeyGenerator # Generate a new url
      # Extract a potential_user with the generated url in the potential_user db
      checkInPotentialUsers = PotentialUser.find_by_url(url)
    end

    return url # Return a unique url
  end
end



#Main controller for the application
class KatibeenController < ApplicationController
  

#Helper Code ----------------------- START ------------------------------------
include UrlKeyGenerator # To generate a unique url key
#Helper Code ------------------------ END ----------------------------------


  #Deals with the request to the root & katibeen/home url
  def home
  end

  #Deals with the post request to the /katibeen/signup url
  def signup

  	email = params[:email]       # Extract the email from the params of the signup form
    timezone = params[:timezone] # Extract the timezone from the params of the signup form
    @url = uniqueUrlKeyGenerator # Generate a unique url key

  	#create a new PotentialUser object with the extarcted email, timezone and url key
  	puser = PotentialUser.new(email: email, url: @url, timezone: timezone)

    # Count all users in the user db with the same email as extracted in the params
    check_users = User.find_by_email(email)
  	
    # If no such user exists
    if check_users == nil

      #If the new PotentialUser is valid and can be saved
    	if puser.save
        # Send an email to the potential user
        PotentialUserMailer.signup_email(puser).deliver
    		# Result instance variable for confirmation in the view
        @result = "Thank you, a confirmation email has been sent to you " + @url

    	#If the new PotentialUser is not valid
    	else
    		#Set @result as the error message 
    		@result = "Email #{puser.errors[:email][0]}.".html_safe
    	end
    # User by this email already exists  
    else
      # Result instance variable for the view
      @result = "User by this email already exists"
    end 

    # Respond to only javascript, set for AJAX
  	respond_to do |format|
  		format.js
  	end
  end

  # Deals with the request to the /katibeen/performance/key url
  def performance
    @param = params[:url]
  end

  # Deals with the request to the katibeen/welcome/key url
  def welcome
    url = params[:url]                      # Extract the url key from the parameters
    puser = PotentialUser.find_by_url(url)  # Extract all users with the same url key
    
    if puser == nil                     
      redirect_to :action => "home"         # Redirect to the home page
    
    # If such a user exists
    else        
      timezone = puser.timezone          # Extract the timezone of this user 
      @email = puser.email               # Extract the email of this user
      puts @email + "\n"
      # Create a new User object with the extracted email, url key and timezone
      user = User.create(email: @email, url: url, timezone: timezone)
      puser.destroy                      # Delete the PotentialUser in the potential_users table 
    end
  end
end

