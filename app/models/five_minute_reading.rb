class FiveMinuteReading < ActiveRecord::Base
  validates :time, presence: true, uniqueness: true
  validates :power, presence: true
  validates :total_power, presence: true
end
