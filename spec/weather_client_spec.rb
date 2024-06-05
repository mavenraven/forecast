# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'WeatherClient' do
  describe 'get_cached_weather_from_lat_lon' do
    it 'caches results correctly' do
      now = Time.utc(2024, 5, 21, 12, 30)
      travel_to now do
        VCR.use_cassette("get_cached_weather_from_lat_lon_zip_caching") do
          result = WeatherClient.get_cached_weather_from_lat_lon 40.71772, -73.95756
          expect(result[:cached_at]).to eq(now)
        end
      end
    end

    it 'returns the correct high and low for the day' do
      VCR.use_cassette("hi_lo_weather_for_lat_lon_zip_11211") do
        result = WeatherClient.get_cached_weather_from_lat_lon 40.71772, -73.95756
        expect(result[:current_temp]).to eq(77)
        expect(result[:forecast]).to eq("Partly Sunny")
      end

    end

    describe 'spot checked against Google results for sanity checking' do
      it "11211" do
        VCR.use_cassette("get_cached_weather_from_lat_lon_zip_11211") do
          result = WeatherClient.get_cached_weather_from_lat_lon 40.71772, -73.95756
          expect(result[:current_temp]).to eq(77)
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

  # Roughly follows the logic outlined here: https://www.chicagotribune.com/2019/02/02/ask-tom-an-explanation-of-our-highlow-temperatures-format/
  describe 'calculate_hi_lo' do
    context "when it's daytime" do
      let(:temps) {
        [
          {
            "temperature" => 68,
            "isDaytime" => true,
          },
          {
            "temperature" => 84,
            "isDaytime" => true,
          },
          {
            "temperature" => 32,
            "isDaytime" => false,
          },
          {
            "temperature" => 99,
            "isDaytime" => false,
          },
          {
            "temperature" => 999,
            "isDaytime" => true,
          },
        ]
      }

      it 'uses the highest temperature during the day for the hi' do
        expect(WeatherClient.calculate_hi_lo(temps)[:hi]). to eq(84)
      end
      it 'uses the lowest temperature during the night for the lo' do
        expect(WeatherClient.calculate_hi_lo(temps)[:lo]). to eq(32)
      end
    end

    context "when it's nightime" do
      let(:temps) {
        [
          {
            "temperature" => 68,
            "isDaytime" => false,
          },
          {
            "temperature" => 84,
            "isDaytime" => false,
          },
          {
            "temperature" => 32,
            "isDaytime" => true,
          },
          {
            "temperature" => 99,
            "isDaytime" => true,
          },
        ]
      }

      it 'uses the lowest temperature during the night for the lo' do
        expect(WeatherClient.calculate_hi_lo(temps)[:lo]). to eq(68)
      end
      it 'uses nil for the hi' do
        expect(WeatherClient.calculate_hi_lo(temps)[:hi]). to eq(nil)
      end
    end
  end
end
