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

  it "gets an address that gives no results" do
    VCR.use_cassette("no_result_address") do
      post "/", params: {address: "1 apple parkway, cuptertino"}
      expect(response.body).to include("not found")
    end
  end

  it "gets a weird address that broke during testing" do
    VCR.use_cassette("a_weird_address_that_broke_during_testing") do
      post "/", params: {address: "kj"}
      expect(response.body).to include("not found")
    end
  end

  it "works with an address that doesn't return a postal code" do
    VCR.use_cassette("an_address_that_doesnt_return_a_postal_code") do
      post "/", params: {address: "222 main street troy mi"}
      expect(response.body).to include("not found")
    end
  end

  it "displays an error if location cannot be retrieved" do
    allow(Geocoder).to receive(:search).and_raise("geocoding error")

    post "/", params: {address: "123 crash avenue"}
    expect(response.body).to include("not retrieve")
  end
end

describe "GET /<zip_code>" do
  it "retrieves the weather for a given zip code" do
    VCR.use_cassette("brooklyn_forecast") do

      get "/11206"

      expect(response.body).to include("Brooklyn")
      temp = Nokogiri::HTML(response.body).css("#temperature_num").text
      expect(temp).to eq("79")
    end
  end

  it "works correctly with address(es) that have a higher confidence than any US address" do
    VCR.use_cassette("high_confidence_non_us") do

      get "/10001"

      expect(response.body).to include("New York")
      temp = Nokogiri::HTML(response.body).css("#temperature_num").text
      expect(temp).to eq("81")
    end
  end

  it "returns an error if theres no results for zip code" do
    allow(Geocoder).to receive(:search).and_return([])

    get "/38485"
    expect(response.body).to include("not retrieve")
  end

  xit "/34343" do
    get "/34343"
    expect(response.body).to include("-144")
  end

  it "redirects to index if not a valid 5 digit zip code" do
    get "/hello"
    expect(response).to redirect_to(forecasts_index_path)
  end

  it "displays a negative temperature correctly" do
    VCR.use_cassette("negative_temperature") do
      get "/11001"
      expect(response.body).to include("-144")
    end
  end

  it "displays an error if location cannot be retrieved" do
    allow(Geocoder).to receive(:search).and_raise("geocoding error")

    get "/12643"
    expect(response.body).to include("Could not")
  end

  xit "displays an error if weather cannot be retrieved" do
    allow(Geocoder).to receive(:search).and_raise("geocoding error")

    get "/11001"
    expect(response.body).to include("Could not")
  end

  it "caches the weather information correctly" do
    VCR.use_cassette("weather_caching") do
      now = Time.utc(2024, 5, 21, 12, 30)
      Timecop.freeze(now) do
        get "/10002"
        expect(response.body).to include("less than a minute ago")
      end

      Timecop.freeze(now + 15.minutes) do
        get "/10002"
        expect(response.body).to include("15 minutes ago")
      end

      Timecop.freeze(now + 31.minutes) do
        get "/10002"
        expect(response.body).to include("less than a minute ago")
      end

      Timecop.return
    end
  end
end
