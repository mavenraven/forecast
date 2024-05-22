# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'WeatherClient' do
  describe 'get cached weather from lat lon' do
    it "happy path" do
      now = Time.utc(2024, 5, 21, 12, 30)
      Timecop.freeze(now) do
        VCR.use_cassette("get_cached_weather_from_lat_lon_happy_path") do
          result = WeatherClient.get_cached_weather_from_lat_lon 40.717089, -73.957901
          expect(result[:current_temp]).to eq(63)
          expect(result[:forecast]).to eq("Mostly Clear")
          expect(result[:cached_at]).to eq(now)
        end
      end
    end
  end
end
