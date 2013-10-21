class FiveMinuteReadingsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create_api]

  def new
  end

  def show
    @reading = FiveMinuteReading.find(params[:id])
  end

  def today
    date = Date.today()
    redirect_to '/five_minute_readings/show_day?date='+date.strftime('%Y-%m-%d')
  end

  def show_day
    date = DateTime.strptime(params[:date], '%Y-%m-%d')
    @year = date.strftime('%Y')
    @month = date.strftime('%m')
    @day = date.strftime('%d')
    @date = @year+'-'+@month+'-'+@day
    respond_to do |format|
      format.html
      format.json {
        tqx = params[:tqx]
        req_id='0'
        sig='0'
        version='0.1'
        if tqx
          tqx.split(';').each do |p|
            val = p.split(':')
            case val[0]
              when /reqId/
                req_id=val[1]
              when /sig/
                sig=val[1]
              when /version/
                version=val[1]
            end
          end
        end

        rows        = []
        date_str = @year.to_s+', '+(@month.to_i-1).to_s+', '+@day.to_s
        total_power = 0.0
        last_time = date
        readings = FiveMinuteReading.where('time >= "'+@date+'" AND time < date("'+@date+'", "+1 day")')
        readings.each do |r|
          if total_power == 0.0
            # Add an initial time
            rows << {c: [{v: 'Date('+date_str+', 00, 00, 00)'},
                         {v: 0.0},
                         {v: total_power.round(3)}
                        ]
                    }
          end
          total_power += r.power / 12
          rows << {c: [{v: r.time.strftime('Date('+date_str+', %H, %M, %S)')},
                       {v: r.power.round(3)},
                       {v: total_power.round(3)}
                      ]
                  }
          last_time = r.time
        end
        last_time = last_time + 5.minutes
        rows << {c: [{v: last_time.strftime('Date('+date_str+', %H, %M, %S)')},
                     {v: 0.0},
                     {v: total_power.round(3)}
                    ]
                }
        rows << {c: [{v: 'Date('+date_str+', 23, 59, 00)'},
                     {v: 0.0},
                     {v: total_power.round(3)}
                    ]
                }
        resp = {version: version, reqId: req_id, status: "ok", sig: sig,
                table: { cols: [{id: 'date', label: 'Time', type: 'datetime', pattern: ''},
                                {id: 'KW',   label: 'kW',   type: 'number',   pattern: ''},
                                {id: 'kWh',  label: 'kWh',  type: 'number',   pattern: ''}],
                         rows: rows
                }
        }
        render json:resp
      }
    end
  end

  def show_month
    @date = params[:date]
    start_date = DateTime.strptime(@date, '%Y-%m')
    @year = start_date.strftime('%Y')
    @month = start_date.strftime('%m')
    respond_to do |format|
      format.html
      format.json {
        tqx = params[:tqx]
        end_date   = start_date + 1.month - 1.day
        rows        = []
        (start_date..end_date).each do |d|
          this_date = d.strftime('%Y-%m-%d')
          power     = FiveMinuteReading.where('time >= "'+this_date+'" AND time < date("'+this_date+'", "+1 day")').sum(:power)/12.0
          year = d.strftime('%Y').to_i
          month = d.strftime('%m').to_i-1
          day = d.strftime('%d').to_i
          rows << {c: [{v: 'Date('+year.to_s+', '+month.to_s+', '+day.to_s+')'},{v: power.round(3)}]}
        end
        req_id='0'
        sig='0'
        version='0.1'
        tqx.split(';').each do |p|
          val = p.split(':')
          case val[0]
            when /reqId/
              req_id=val[1]
            when /sig/
              sig=val[1]
            when /version/
              version=val[1]
          end
        end
        resp = {version: version, reqId: req_id, status: "ok", sig: sig,
                 table: { cols: [{id: 'date', label: 'Date', type: 'datetime', pattern: ''},
                                 {id: 'date', label: 'kWh', type: 'number', pattern: ''}],
                          rows: rows
                        }
               }
        render json:resp
      }
    end
  end

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
