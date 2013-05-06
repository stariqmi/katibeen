class PerformanceController < ApplicationController
include PerformanceHelper

  def performance
  
    user = User.find_by_url(params[:url])
    
    begin

      if !user.registered
        redirect_to :controller => "users", :action => "welcome", :url => params[:url]

      else
        data = OutgoingDayPrayer.where(:url => params[:url], :status => "pending")
        if !data[0].nil?
          a = 1
          data = data[0]
          redirect_to :controller => "data", :action =>"requestData", :url => params[:url], :prayer_day_id => data.id, :error => "This day's salat info was not filled out"

        else
          url = params[:url] # Extract the url-key from the parameters
          # Find the user with the url, eager leading the prayer data aswell.
          @user = User.includes(:outgoing_day_prayers).find_by_url(url)
          rows = OutgoingDayPrayer.where(:url => url)
          if @user == nil
            redirect_to :controller => "katibeen", :action => "home" unless request.post? # Redirect to the home page
          elsif @user.outgoing_day_prayers.count == 0
            redirect_to :controller => "users", :action => "welcome", :url => params[:url]
          else
            if @user.registered == false
              redirect_to :controller => "katibeen", :action => "home" unless request.post?

            else

              # Check of the user is visiting after the welcome page
              time = rows[1].updated_at.in_time_zone("America/New_York")
              now = Time.now.in_time_zone("America/New_York")
              @show_intro = false
              min_diff = (Time.parse(now.to_s) - Time.parse(time.to_s))/60
              if min_diff < 2 ? @show_intro = true : @show_intro = false
            end

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

    rescue Exception => e
      puts e
      redirect_to '/500'
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
		  redirect_to :controller => "katibeen", :action => "home" # Redirect to the home page

		elsif @user.outgoing_day_prayers.count > 3
		    redirect_to :action => "performance"
		else
		  @days_left = 3 - @user.outgoing_day_prayers.count
		end
	end

end
