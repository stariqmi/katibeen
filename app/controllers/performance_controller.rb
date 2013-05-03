class PerformanceController < ApplicationController
include UserPerformanceDataHelper

  def performance
  
    user = User.find_by_url(params[:url])
    if !user.registered
      redirect_to :action => "welcome", :url => params[:url]
    else
      data = OutgoingDayPrayer.where(:url => params[:url], :status => "pending")
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
          if @user.registered == false
            redirect_to :action => "home" unless request.post?

          else

            # Check of the user is visiting after the welcome page
            time = rows[1].updated_at.in_time_zone("America/New_York")
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
