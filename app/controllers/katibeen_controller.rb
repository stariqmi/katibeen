#Main controller for the application
class KatibeenController < ApplicationController
  

#Helper Code ----------------------- START ------------------------------------
include UrlKeyGeneratorHelper # To generate a unique url key
# include TimeZoneManager
include UserPerformanceDataHelper # To generate missed prayers data for a user
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

    # Find the user in the user db with the same email as extracted in the params
    check_users = User.find_by_email(email)
  	
    # If no such user exists
    if check_users == nil

      #If the new PotentialUser is valid and can be saved
    	if puser.save
        # Send an email to the potential user
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
    url = params[:url]                            # Extract the url-key from the parameters
    # Find the user with the url, eager leading the prayer data aswell.
    user = User.includes(:incoming_day_prayers).find_by_url(url)
    rawData = rawDataExtractor user               # Extracts all the day prayers of the user
   # If no such user exists
   if user == nil
      redirect_to :action => "home"               # Redirect to the home page
    else
      @data = user.incoming_day_prayers           # Extract all the prayer data
      missedData = missedPrayerData rawData       # Extract all the missed prayer data
      processedData = { missedPrayerData: missedData}
      @json = processedData.as_json
    end
  end



  # Deals with the request to the katibeen/welcome/key url
  def welcome
    url = params[:url]                      # Extract the url key from the parameters
    puser = PotentialUser.find_by_url(url)  # Extract the user with the same url key
    
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

