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

    begin
      best_result = GeocoderHelpers.cached_best_result @address.value
    rescue
      @general_error = "Could not retrieve address."
      render :index and return
    end

    if best_result.nil? or best_result.postal_code.empty?
      @general_error = "Address not found."
      render :index and return
    end

    redirect_to action: "show", id: best_result.postal_code
  end

  def show
    zip_code = ZipCode.new(value: params[:id])

    if not zip_code.valid?
      @address = Address.new
      redirect_to action: "index" and return
    end

    # The weather API used only takes lat/lon, and not zip codes.
    # So before we
    begin
      best_result = GeocoderHelpers.cached_best_result zip_code.value
    rescue
      @general_error = "Could not retrieve weather."
      render :show and return
    end

    if best_result.nil?
      @general_error = "Could not retrieve weather."
      render :show and return
    end

    coords = {lat: best_result.latitude, lon: best_result.longitude}
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
    # Forecasts can come in as 'Chance Showers And Thunderstorms then Partly Cloudy', which isn't great for the UI layout
    @forecast = cached[:forecast_data]["properties"]["periods"][0]["shortForecast"].split[0..1].join(' ')
    @cached_at = cached[:cached_at]
    @location = best_result.city.nil? ? best_result.county : best_result.city
  end
end
