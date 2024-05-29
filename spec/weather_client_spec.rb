# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'WeatherClient' do
  it 'caches results correctly' do
    now = Time.utc(2024, 5, 21, 12, 30)
    travel_to now do
      VCR.use_cassette("get_cached_weather_from_lat_lon_zip_caching") do
        result = WeatherClient.get_cached_weather_from_lat_lon 40.71772, -73.95756
        expect(result[:cached_at]).to eq(now)
      end
    end
  end

  describe 'spot checked against Google results for sanity checking' do
    it "11211" do
      VCR.use_cassette("get_cached_weather_from_lat_lon_zip_11211") do
        result = WeatherClient.get_cached_weather_from_lat_lon 40.71772, -73.95756
        expect(result[:current_temp]).to eq(75)
        expect(result[:forecast]).to eq("Partly Sunny")
      end
    end
    it "78719" do
      VCR.use_cassette("get_cached_weather_from_lat_lon_zip_78719") do
        result = WeatherClient.get_cached_weather_from_lat_lon 30.1900, -97.6687
        expect(result[:current_temp]).to eq(88)
        expect(result[:forecast]).to eq("Mostly Sunny")
      end
    end
    it "90401" do
      VCR.use_cassette("get_cached_weather_from_lat_lon_zip_90401") do
        result = WeatherClient.get_cached_weather_from_lat_lon 34.010090, -118.496948
        expect(result[:current_temp]).to eq(63)
        expect(result[:forecast]).to eq("Sunny")
      end
    end
  end
end
