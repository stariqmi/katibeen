class DataController < ApplicationController
include UserPerformanceDataHelper

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

    if !params[:welcome].nil?
      user = User.find_by_url(params[:url])
      user.registered = true
      user.save
    end

   # This section sets values to the performed/not-performed prayers.
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
      redirect_to :controller => "katibeen", :action => "home"
    else
      if dataCount == 2
         if params[:first_day]
            puts ">>>>>>>FIRST DAY<<<<<<<"
            puts counter
            dayData.update_attribute(:average, counter)
         else
          if !data[0]
            avg = (counter + data[-1].total_prayed) / 2.to_f
            dayData.update_attribute(:average, avg)
          else
            avg = (counter + data[0].total_prayed) / 2.to_f
            dayData.update_attribute(:average, avg)
          end
         end


      end
      @redirect = nil
      if params[:submitButton]
        @redirect = root_url() + params[:url]
        @title = "Success!"
        @result = "You have successfully added your salat data"
        @result2 = "Wait to be redirected"
      elsif params[:fromEmail] == "true"
        url = root_url() + params[:url]
        redirect_to url
      else
        @title = "Success!"
        @result = "You have successfully added your salat data"
        @result2 = "This page will close"
      end
      dayData.save
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

end
