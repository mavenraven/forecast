require 'rails_helper'
require 'pry'

RSpec.describe "Forecasts", type: :request do
  describe "GET index" do
    it "renders the index page" do
      get "/"
      expect(response.body).to include("Weather")
    end
  end

  describe "GET show" do
    it "retrieves the weather for a given zip code" do
      get "/95014"
      expect(response.body).to include("Cupertino")
      expect(response.body).to include("75°")
    end
  end
end
