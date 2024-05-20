require 'rails_helper'

RSpec.describe "Forecasts", type: :request do
  describe "GET /" do
    it "renders the index page" do
      get "/"
      expect(response.body).to include("Weather")
    end
  end

  describe "POST /" do
    it "redirects to the appropriate zip code" do
      post "/", params: {form: {address_input: "1 Apple Park Way. Cupertino, CA"}}
      expect(response).to redirect_to(forecasts_show_path(95014))
    end
  end

  describe "GET /<zip_code>" do
    it "retrieves the weather for a given zip code" do
      get "/95014"

      expect(response.body).to include("Cupertino")
      expect(response.body).to include("75°")
    end
  end
end
