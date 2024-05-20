require 'rails_helper'

RSpec.feature "Getting Forecasts", type: :feature do
  scenario "user is able to retrieve a forecast" do
    visit root_path
    expect(page).to have_content("Weather")

    fill_in "address_input", with: "1 Apple Park Way. Cupertino, CA"
    click_button 'submit'

    expect(page).to have_content("Data last updated at")
    expect(page).to have_content("Cupertino")
    expect(page).to have_content("75°")
  end
end
