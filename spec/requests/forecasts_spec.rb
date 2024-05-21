require 'rails_helper'

#TODO: set up webmock
RSpec.describe "Forecasts", type: :request do
  describe "GET /" do
    it "renders the index page" do
      get "/"
      expect(response.body).to include("Weather")
    end
  end

  describe "POST /" do
    it "redirects to the appropriate zip code" do
      VCR.use_cassette("forecast_redirect") do

        post "/", params: {address: "1 Apple Park Way. Cupertino, CA"}
        expect(response).to redirect_to(forecasts_show_path(94087))
      end
    end

    it "returns to index with an error for bad input" do
      post "/", params: {address: "<>"}
      expect(response.body).to include("contains invalid characters")
    end

    it "skips hitting the geocoder if we can special case a 5 digit zip code" do
      post "/", params: {address: "94087"}
      expect(response).to redirect_to(forecasts_show_path(94087))
    end
  end

end

describe "GET /<zip_code>" do
  it "retrieves the weather for a given zip code" do
    VCR.use_cassette("brooklyn_forecast") do

      get "/11206"

      expect(response.body).to include("Brooklyn")
      temp = Nokogiri::HTML(response.body).css("#temperature").text
      expect(temp).to eq("79")
    end
  end

  it "works correctly with address(es) that have a higher confidence than any US address" do
    #    VCR.use_cassette("high_confidence_non_us") do

      get "/10001"

      expect(response.body).to include("New York")
      temp = Nokogiri::HTML(response.body).css("#temperature").text
      expect(temp).to eq("81")
    #end
  end

  it "redirects to index if not a valid 5 digit zip code" do
    get "/hello"

    expect(response).to redirect_to(forecasts_index_path)
  end

  it "displays a negative temperature correctly" do

  end

  it "displays the correct caching time value" do

  end
end
