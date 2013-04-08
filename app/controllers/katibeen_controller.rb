#Main controller for the application
class KatibeenController < ApplicationController

 protect_from_forgery :except => :performance


#Helper Code ----------------------- START ------------------------------------
include UrlKeyGeneratorHelper # To generate a unique url key
# include TimeZoneManager
include UserPerformanceDataHelper # To generate missed prayers data for a user
#Helper Code ------------------------ END ----------------------------------

  #Deals with the request to the root & katibeen/home url
  def home
  end

  # Controller for the about page
  def about
  end

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
      end
    #User by this email already exists
    else
      if !check_users.registered?
      # Result instance variable for the view
      @title = "Looks like something went wrong ..."
      @result = "User by this email already exists, but we sent another confirmation email just in case"
      end
    end

    # Respond to only javascript, set for AJAX
   respond_to do |format|
   format.js
   end
  end

  # Deals with the request to the /katibeen/performance/key url
  def performance
    if request.post?
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
          if dataCount == 2
             if params[:prayer_day_id] == data[0].id
                dayData.update_attribute(:average, counter)
             else
                avg = (counter + data[0].total_prayed) / 2.to_f
                dayData.update_attribute(:average, avg)
             end
          elsif dataCount < 15
            avg = (counter + data[dataCount - 2].total_prayed) / dataCount.to_f
            dayData.update_attribute(:average, avg.round(2))
          else
            to_subtract = dayData[counter - 16].total_prayed / 15.to_f
            to_add = total_prayed / 15.to_f
            avg = (dayData[counter - 2].average + to_add - to_subtract).round(2)
            dayData.update_attribute(:average, avg)
          end
          dayData.save
          puts dayData.average
          redirect_to :action => "performance"
        end
    end

      data = OutgoingDayPrayer.where(:url => params[:url], :fajr => nil)
      if !data[0].nil?
        a = 1
        data = data[0]
        redirect_to :action =>"requestData", :url => params[:url], :prayer_day_id => data.id, :error => "Mail Client Not Supported"
    else
      url = params[:url] # Extract the url-key from the parameters
      # Find the user with the url, eager leading the prayer data aswell.
      @user = User.includes(:outgoing_day_prayers).find_by_url(url)
      rows = OutgoingDayPrayer.where(:url => url)
      if @user == nil
        redirect_to :action => "home" unless request.post? # Redirect to the home page
      elsif @user.outgoing_day_prayers.count == 0
        redirect_to :action => "welcome", :url => params[:url]
      else
        puts @user.outgoing_day_prayers.count
        if @user.registered == false
          redirect_to :action => "home" unless request.post?

        else

          # Check of the user is visiting after the welcome page
          time = rows[1].updated_at.in_time_zone("America/New_York")
          puts "Time = #{time}"
          year = time.strftime("%Y").to_i
          month = time.strftime("%m").to_i
          day = time.strftime("%d").to_i
          hour = time.strftime("%H").to_i
          minutes = time.strftime("%M").to_i
          now = Time.now.in_time_zone("America/New_York")
          year_now = now.strftime("%Y").to_i
          month_now = now.strftime("%m").to_i
          day_now = now.strftime("%d").to_i
          hour_now = now.strftime("%H").to_i
          minutes_now = now.strftime("%M").to_i
          @show_intro = ""
          min_diff = minutes_now - minutes
          if year == year_now && month == month && day == day_now && hour == hour_now && min_diff < 2 ? @show_intro = true : @show_intro = false
          end
          # Check ends here

          @url = params[:url]
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
          @improvement_prefix = if @improvement >= 0
            "improved"
          else
            "reduced"
          end
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

    @modul_title = ""
    # If no such user exists
    if @user == nil
      redirect_to :action => "home" # Redirect to the home page

    # If such a @user exists
    else

      time = Time.now.in_time_zone(@user.timezone).strftime("%H")
      time = time.to_i
      puts "--------TIME-------" + time.to_s + "-------------------"
      data = OutgoingDayPrayer.where(:url => params[:url])
      if data[0].nil?

        if time >= 22
          @today = true
          #Creates prayer data based on today since 10PM has passed
          today = Time.now.in_time_zone(@user.timezone)
          yesterday = Chronic.parse('yesterday')
          @dayData_prev = OutgoingDayPrayer.create(url: @user.url, weekday: yesterday.strftime("%A"), user_id: @user_id, status: "pending", average: 0)
          puts @dayData_prev.id
          @dayData = OutgoingDayPrayer.create(url: @user.url, weekday: today.strftime("%A"),
                                              user_id: @user.id, status: "pending", average: 0)
          puts @dayData.id
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
          puts @dayData_prev.id
          puts @dayData.id
          @prayer_day_id = @dayData.id
          @prayer_day_id_prev = @dayData_prev.id
          @last_form_title = "(#{date.strftime('%B, %d')})"
          @modul_title = "(#{day_bfr_yesterday.strftime('%B, %d')})"
        end

      else
        @dayData = data[1]
        puts @dayData
        @prayer_day_id = @dayData.id
        @dayData_prev = data[0]
        @modul_title = "on #{@dayData_prev.created_at.strftime('%B, %d')}"
        @last_form_title = "(#{@dayData.created_at.strftime('%B, %d')})"
        puts @dayData_prev.inspect
        @prayer_day_id_prev = @dayData_prev.id
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
    if !params[:error].nil?
      @error_message = "Seems like you missed a day, or you are using a mail client that does not support our services"
      @data = OutgoingDayPrayer.find_by_id( params[:prayer_day_id])
    end
    @prayer_day_id = params[:prayer_day_id]
    @url = params[:url]
    @dash = root_url() + @url
    @dash = @dash[7..-1]
  end

  def submitDayData
    puts ""
    puts ""
    puts ""
    puts "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
    puts ""
    puts ""
    puts ""

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

      # Look for all the rows for that user
      data = OutgoingDayPrayer.where(:url => params[:url])
      # Count them
      dataCount = data.count
      # Find the specific row for which data is submitted
      dayData = OutgoingDayPrayer.find(params[:prayer_day_id])
      # Update the row
      dayData.update_attributes(fajr: prayerData[:fajr], zuhr: prayerData[:zuhr], asr: prayerData[:asr], maghrib: prayerData[:maghrib], isha: prayerData[:isha], total_prayed: counter, status: "responded")
    if dayData == nil
      @title = 'Oops!'
      @result = "Something went wrong"
      redirect_to :action => "home"
    else
      if dataCount == 2
          puts data[0].inspect
         puts ">>>>>>>>>>>>>>>>>> WE ARE IN FIRST 2 DAYS<<<<<<<<<<<<<<<<<<<"
         if params[:first_day]
            puts ">>>>>>>FIRST DAY<<<<<<<"
            puts counter
            dayData.update_attribute(:average, counter)
         else
            puts ">>>>>>>>>>>>>>SECOND DAY<<<<<<<<<<<<<<<"
            avg = (counter + data[0].total_prayed) / 2.to_f
            dayData.update_attribute(:average, avg)
            puts dayData.average
         end
      elsif dataCount < 15
        puts "I am less than 15!!!"
        puts data[dataCount - 2].inspect
        puts counter
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
      elsif params[:fromEmail] == "true"
        url = root_url() + params[:url]
        redirect_to url
        puts url
      else
        @title = "Success!"
        @result = "You have successfully added your salat data"
        @result2 = "This page will close"
      end
      dayData.save
      puts dayData.average
    end

    if params[:welcome].nil?
      respond_to do |format|
        format.js
      end
    else
      respond_to do |format|
        format.js {render :nothing => true}
      end
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
