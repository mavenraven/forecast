require 'rails_helper'

RSpec.feature "Getting Forecasts", type: :feature do
  scenario "user is able to retrieve a forecast" do
    VCR.use_cassette("e2e") do
      visit "/"
      expect(page).to have_content("Weather")

      fill_in "address", with: "10001"
      click_button 'submit'

      expect(page).to have_content("last updated")
      expect(page).to have_content("New York")
      expect(page).to have_content("81")
    end
  end
end
