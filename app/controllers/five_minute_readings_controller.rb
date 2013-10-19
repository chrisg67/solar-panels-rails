class FiveMinuteReadingsController < ApplicationController
  def new
  end

  def show
    @reading = FiveMinuteReading.find(params[:id])
  end

  def show_day
    @date = params[:date]
    @readings = FiveMinuteReading.where('time >= "'+@date+'" AND time < date("'+@date+'", "+1 day")')
  end

  def show_month
    @date = params[:date]
    @start_date = Date.strptime(@date, '%Y-%m')
    @end_date   = @start_date + 1.month - 1.day
    @readings   = []
    (@start_date..@end_date).each do |d|  
      @this_date = d.strftime('%Y-%m-%d')
      @power     = FiveMinuteReading.where('time >= "'+@this_date+'" AND time < date("'+@this_date+'", "+1 day")').sum(:power)/12.0
      @readings << { date: @this_date, power_kWh: @power }
    end
  end

  skip_before_action :verify_authenticity_token, only: [:create_api]

  def create
    time = params[:reading][:time]
    other_reading = FiveMinuteReading.find_by(:time, time)
    @reading = FiveMinuteReading.new(time: time,
                                     power: params[:reading][:power],
                                     total_power: params[:reading][:total_power])
    if @reading.save
      flash.now[:success] = "Entry Accepted"
      render 'new'
    else
      flash.now[:error] = @reading.errors.full_messages.first
      render 'new'
    end
  end

  def create_api
    #TODO: Should add an API key to this
    time = params[:reading][:time]
    other_reading = FiveMinuteReading.find_by(:time, time)
    @reading = FiveMinuteReading.new(time: time,
                                     power: params[:reading][:power],
                                     total_power: params[:reading][:total_power])
    if @reading.save
      render text: ":)"
    else
      render text: @reading.errors.full_messages.first,  status: 400
    end
  end
end
