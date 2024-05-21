require 'pry'

class ForecastsController < ApplicationController
  def index
    @address = Address.new
  end

  def create
    zip_code = ZipCode.new(value: params[:address])
    if zip_code.valid?
      redirect_to action: "show", id: zip_code.value and return
    end

    @address = Address.new(value: params[:address])

    if not @address.valid?
      render :index and return
    end

    highest = Rails.cache.fetch @address.value, skip_nil: true, expires_in: 30.minutes do
      begin
        results = Geocoder.search(@address.value)
      rescue
        @general_error = "Could not retrieve address."
        render :index and return
      end

      highest = GeocoderHelpers.best_result(results)
      if highest.nil? or highest.postal_code.empty?
        @general_error = "Address not found."
        render :index and return
      end
      highest
    end

    redirect_to action: "show", id: highest.postal_code
  end

  def show
    zip_code = ZipCode.new(value: params[:id])

    if not zip_code.valid?
      @address = Address.new
      redirect_to action: "index" and return
    end

    highest = Rails.cache.fetch zip_code.value, skip_nil: true, expires_in: 30.minutes do
      logger.debug "missed cache for lat lon"

      begin
        results = Geocoder.search(zip_code.value)
      rescue
        @general_error = "Could not retrieve weather."
        render :show and return
      end

      highest = GeocoderHelpers.best_result(results)
      if highest.nil?
        #TODO: fix me
        raise 'fixme'
      end
      highest
    end

    coords = {lat: highest.latitude, lon: highest.longitude}
    cached = Rails.cache.fetch coords, skip_nil: true, expires_in: 30.minutes do
      logger.debug "missed cache for weather data"

      grid_url  = "https://api.weather.gov/points/#{coords[:lat]},#{coords[:lon]}"
      grid_resp = HTTParty.get(grid_url)
      grid_data = JSON.parse(grid_resp)
      forecast_url = grid_data["properties"]["forecast"]

      forecast_resp = HTTParty.get(forecast_url)
      {forecast_data: JSON.parse(forecast_resp), cached_at: Time.now}
    end

    @current_temp = cached[:forecast_data]["properties"]["periods"][0]["temperature"]
    @cached_at = cached[:cached_at]
    @location = highest.county
  end
end
