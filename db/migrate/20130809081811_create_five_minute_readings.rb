class CreateFiveMinuteReadings < ActiveRecord::Migration
  def change
    create_table :five_minute_readings do |t|
      t.datetime :time
      t.float :power
      t.float :total_power

      t.timestamps
    end
  end
end
