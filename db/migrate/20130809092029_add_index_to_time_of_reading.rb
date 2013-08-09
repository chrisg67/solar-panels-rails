class AddIndexToTimeOfReading < ActiveRecord::Migration
  def change
    add_index :five_minute_readings, :time, unique: true
  end
end
