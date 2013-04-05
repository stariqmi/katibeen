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
    old_user = User.find_by_email(email)

    if !old_user.nil?
      if !old_user.registered?
        old_user.sendWelcomeEmail
        old_user.save
      end
    end
    #create a new PotentialUser object with the extarcted email, timezone and url key
    user = User.new(email: email, url: @url, timezone: timezone, day: 1, registered: false)

    # Find the user in the user db with the same email as extracted in the params
    check_users = User.find_by_email(email)

    # If no such user exists
    if check_users.nil?

    #If the new PotentialUser is valid and can be saved
      if user.save
        user.sendWelcomeEmail
        #Result instance variable for confirmation in the view
        @title = "Thank you for signing up"
        @result = "A confirmation email with instructions has been sent to you"
        @result2 = "Your unique access key is: " + @url

      #If the new PotentialUser is not valid
      else
       #Set @result as the error message
       @title = "Looks like something went wrong ..."
       @result = "Email #{user.errors[:email][0]}.".html_safe
         if @result == "User by this email already exists"
            @result = @result + ", but we sent another confirmation email just in case"
         end
      end
    #User by this email already exists
    else
      # Result instance variable for the view
      @title = "Looks like something went wrong ..."
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
      puts @user.outgoing_day_prayers.count
      if @user.registered == false
        redirect_to :action => "home"
      elsif @user.outgoing_day_prayers.count < 3
        redirect_to :action => "temporary"
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
      mainWidgetData = performance.mainWidgetData
      @mainWidgetData = mainWidgetData[:data]
      @dotSVG = mainWidgetData[:path]
      lineGraphData = performance.lineGraphData
      @lineGraphPath = lineGraphData[:lineGraphPath]
      @startHeight = lineGraphData[:startHeight]
      @endHeight = lineGraphData[:endHeight]
      @startAvg = lineGraphData[:startAvg]
      @endAvg = lineGraphData[:endAvg]
      @improvement = lineGraphData[:improvement].to_i
        @improvement_prefix = if @improvement > 0
          "improved"
        else
          "reduced"
        end
      end
    end
  end

  # Deals with the request to the katibeen/welcome/key url
  def welcome

    require 'chronic'

    url = params[:url] # Extract the url key from the parameters
    @user = User.find_by_url(url)
    @url = url


    if @user == nil
      redirect_to :action => "home" # Redirect to the home page

    # If such a @user exists
    else

      time = Time.now.in_time_zone(@user.timezone).strftime("%H")
      time = time.to_i
      data = OutgoingDayPrayer.where(:url => params[:url])
      if data[0].nil?

        if time >= 22
          @today = true
          #Creates prayer data based on today since 10PM has passed
          @dayData = OutgoingDayPrayer.create(url: @user.url, weekday: Time.now.in_time_zone(@user.timezone).strftime("%A"),
                                              user_id: @user.id, status: "pending", average: 0)

          @prayer_day_id = @dayData.id

        else
          #If it is less than 10PM we use yesterday for the prayer data
          #Chronic.now = Time.now.in_time_zone(@user.timezone)
          date = Chronic.parse('yesterday')
          weekday = date.strftime("%A")
          @dayData = OutgoingDayPrayer.create(url: @user.url, weekday: weekday,
                                              user_id: @user.id, status: "pending", average: 0)
          @prayer_day_id = @dayData.id
        end

      else
        puts '----------------------------------'
        @dayData = data[0]
        puts @dayData
        @prayer_day_id = @dayData.id

      end

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
    @url = params[:url]
    @dash = root_url() + @url
    @dash = @dash[7..-1]
  end

  def submitDayData
    prayer = [:fajr, :zuhr, :asr, :maghrib, :isha]
    prayerData = {}
    counter = 0
    prayer.each do |p|
      if params[p].nil?
        prayerData[p] = 0
      elsif params[p].to_s == "2"
        prayerData[p] = 2
        counter += 1
      else
        nil
      end
    end
    puts params[:url]
    data = OutgoingDayPrayer.where(:url => params[:url])
    dataCount = data.count
    dayData = OutgoingDayPrayer.find(params[:prayer_day_id])
    puts dayData.average
    dayData.update_attributes(fajr: prayerData[:fajr], zuhr: prayerData[:zuhr], asr: prayerData[:asr], maghrib: prayerData[:maghrib], isha: prayerData[:isha], total_prayed: counter, status: "responded")
    if dayData == nil
      @title = 'Oops!'
      @result = "Something went wrong"
      redirect_to :action => "home"
    else
      if dataCount == 1
        avg = (counter / dataCount.to_f).round(2)
        dayData.update_attribute(:average, avg)
      elsif dataCount < 15
        avg = (counter + data[dataCount - 2].total_prayed) / dataCount.to_f
        dayData.update_attribute(:average, avg.round(2))
      else
        to_subtract = dayData[counter - 16].total_prayed / 15.to_f
        to_add = total_prayed / 15.to_f
        avg = (dayData[counter - 2].average + to_add - to_subtract).round(2)
        dayData.update_attribute(:average, avg)
      end
      puts params[:submitButton]
      @redirect = nil
      if params[:submitButton]
        @redirect = root_url() + params[:url]
        @title = "Success!"
        @result = "You have successfully added your salat data"
        @result2 = "Wait to be redirected"
        puts @redirect
      else
        @title = "Success!"
        @result = "You have successfully added your salat data"
        @result2 = "This page will close"
      end
      dayData.save
      puts dayData.average
    end
    respond_to do |format|
      format.js
    end
  end

  # Deals with the request to the katibeen/unsubscribe/key url
  def unsubscribe
    url = params[:url] # Extract the url key from the parameters
    @user = User.find_by_url(url)

    if @user == nil
      redirect_to :action => "home" # Redirect to the home page

    # If such a user exists
    else
      @user.sendUnsubscribe
      @user.registered = false
      @user.save!
    end
  end

  def temporary
    url = params[:url] # Extract the url key from the parameters
    @user = User.find_by_url(url)

    if @user == nil
      redirect_to :action => "home" # Redirect to the home page

    elsif @user.outgoing_day_prayers.count > 3
        redirect_to :action => "performance"
    else
      @days_left = 3 - @user.outgoing_day_prayers.count
    end

  end


end
