require 'spec_helper'

describe "Five Minute Reading Pages" do
  subject { page }

  describe "new reading page" do
    before { visit new_five_minute_reading_path }
    it { should have_content('New Reading') }
    it { should have_title(full_title('New Reading')) }
  end
end