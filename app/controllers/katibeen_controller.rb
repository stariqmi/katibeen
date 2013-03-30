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

  def about
  end

  #Deals with the post request to the /katibeen/signup url
  def signup

    email = params[:email] # Extract the email from the params of the signup form
    timezone = params[:timezone] # Extract the timezone from the params of the signup form
    @url = uniqueUrlKeyGenerator # Generate a unique url key

    #create a new PotentialUser object with the extarcted email, timezone and url key
    user = User.new(email: email, url: @url, timezone: timezone, day: 1)

    # Find the user in the user db with the same email as extracted in the params
    check_users = User.find_by_email(email)

    # If no such user exists
    if check_users.nil?

    #If the new PotentialUser is valid and can be saved
      if user.save!
        #Result instance variable for confirmation in the view
        @result = "Thank you, a confirmation email has been sent to you " + @url

      #If the new PotentialUser is not valid
      else
       #Set @result as the error message
       @result = "Email #{user.errors[:email][0]}.".html_safe
      end
    #User by this email already exists
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
    url = params[:url] # Extract the url-key from the parameters
    # Find the user with the url, eager leading the prayer data aswell.
    @user = User.includes(:outgoing_day_prayers).find_by_url(url)
    if @user == nil
      redirect_to :action => "home" # Redirect to the home page
    else
      performance = PerformanceData.new @user # New PerformanceData object
      @data = performance.rawData # Raw Data from the object
      @weeks = performance.weeks # Weeks passed since joined katibeen.com
      prayersData = performance.prayersData
      @average = performance.userAvgCalculator
      @longestStreak = performance.longestStreak
      # Filtered data using PerformanceData instance functions
      @filteredData = {
                        missedPrayerData: prayersData[:missedPrayersData],
                        weeklyPerformedAvgData: prayersData[:weeklyPerformedAvgData],
                        avgWeekdayData: prayersData[:weekdayAvgPrayersData]
                    }
      @mainWidgetData = performance.mainWidgetData
      @lineGraphData = "hello"
    end
  end

  # Deals with the request to the katibeen/welcome/key url
  def welcome
    url = params[:url] # Extract the url key from the parameters
    @user = User.find_by_url(url)

    if @user == nil
      redirect_to :action => "home" # Redirect to the home page

    # If such a user exists
    else
      @user.registered = true
      @user.save!
    end
  end

  def widgetData
   url = params[:url]
   user = User.find_by_url(url)
   performance = PerformanceData.new user
   @data = performance.mainWidgetData

   respond_to do |format|
   format.json { render json: @data }
   end
  end

  def requestData
    @prayer_day_id = params[:prayer_day_id]
  end

  def submitDayData
    params.each do |key, param|
      params[key] = 0 if param == nil
    end
    totalPrayed = (params[:fajr] + params[:zuhr] + params[:asr] + params[:maghrib] + params[:isha])/2
    data = OutgoingDayPrayer.find_by_url(params[:url])
    dataCount = data.count
    dayData = OutgoingDayPrayer.find(params[:prayer_day_id])
    dayData.update_attributes(fajr: params[:fajr], zuhr: params[:zuhr], asr: params[:asr], maghrib: params[:maghrib], isha: params[:isha], total_prayed: totalPrayed)
    if dayData == nil
      redirect_to :action => "home"
    else
      if dataCount <= 15
        
      else
      end

    end
    respond_to do |format|
      format.js
    end
  end

end
