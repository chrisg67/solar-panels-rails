require 'spec_helper'

describe FiveMinuteReading do
  before { @reading = FiveMinuteReading.new(time: "2013-08-07 10:05:00", power: 0.2, total_power: 5888.0 ) }

  subject { @reading }
  it { should respond_to(:time) }
  it { should respond_to(:power) }
  it { should respond_to(:total_power) }

  describe "when time is missing" do
    it "should not be valid" do
      @reading.time = nil
      expect(@reading).not_to be_valid
    end
  end

  describe "when power is missing" do
    it "should not be valid" do
      @reading.power = nil
      expect(@reading).not_to be_valid
    end
  end

  describe "when total_power is missing" do
    it "should not be valid" do
      @reading.total_power = nil
      expect(@reading).not_to be_valid
    end
  end

  describe "when time is already used" do
    before do
      reading_with_duplicate_time = @reading.dup
      reading_with_duplicate_time.save
    end

    it { should_not be_valid }
  end

  describe "when an entry with the same power is supplied" do
    before do
      reading_with_duplicate_power = @reading.dup
      reading_with_duplicate_power.time = "2013-12-31 00:00:00"
      reading_with_duplicate_power.total_power = 0
      reading_with_duplicate_power.save
    end

    it { should be_valid }
  end

  describe "when an entry with the same total_power is supplied" do
    before do
      reading_with_duplicate_total_power = @reading.dup
      reading_with_duplicate_total_power.time = "2013-12-31 00:00:00"
      reading_with_duplicate_total_power.power = 0
      reading_with_duplicate_total_power.save
    end

    it { should be_valid }
  end
end
