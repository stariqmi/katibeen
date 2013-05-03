class KatibeenController < ApplicationController

include UrlKeyGeneratorHelper
include UserPerformanceDataHelper

  def home
  end

  def about
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
