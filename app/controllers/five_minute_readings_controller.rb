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
