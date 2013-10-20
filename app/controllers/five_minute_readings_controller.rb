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
    start_date = DateTime.strptime(@date, '%Y-%m')
    @year = start_date.strftime('%Y')
    @month = start_date.strftime('%m')
    tqx = params[:tqx]
    respond_to do |format|
      format.html
      format.json {
        end_date   = start_date + 1.month - 1.day
        rows        = []
        (start_date..end_date).each do |d|
          this_date = d.strftime('%Y-%m-%d')
          power     = FiveMinuteReading.where('time >= "'+this_date+'" AND time < date("'+this_date+'", "+1 day")').sum(:power)/12.0
          year = d.strftime('%Y').to_i
          month = d.strftime('%m').to_i-1
          day = d.strftime('%d').to_i
          rows << {c: [{v: 'Date('+year.to_s+', '+month.to_s+', '+day.to_s+')'},{v: power}]}
        end
        reqId='0'
        sig='0'
        version='0.1'
        tqx.split(';').each do |p|
          val = p.split(':')
          case val[0]
            when /reqId/
              reqId=val[1]
            when /sig/
              sig=val[1]
            when /version/
              version=val[1]
          end
        end
        resp = {version: version, reqId: reqId, status: "ok", sig: sig,
                 table: { cols: [{id: 'date', label: 'Date', type: 'datetime', pattern: ''},
                                 {id: 'date', label: 'kWh', type: 'number', pattern: ''}],
                          rows: rows
                        }
               }
        render json:resp
      }
    end
  end

  #def get_month_data
  #  month = params[:month]
  #  start_date = Date.strptime(@date, '%Y-%m')
  #  end_date   = @start_date + 1.month - 1.day
  #  readings   = []
  #  (start_date..end_date).each do |d|
  #    this_date = d.strftime('%Y-%m-%d')
  #    power     = FiveMinuteReading.where('time >= "'+@this_date+'" AND time < date("'+@this_date+'", "+1 day")').sum(:power)/12.0
  #    readings << { date: @this_date, power_kWh: @power }
  #
  #end

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
