require 'pry'

class ForecastsController < ApplicationController
  def index
    @address = Address.new
  end

  def create
    @address = Address.new(value: params[:address])

    if not @address.valid?
      render :index and return
    end

    results = Geocoder.search(@address.value)
    highest = GeocoderHelpers.highest_confidence(results)

    redirect_to action: "show", id: highest.postal_code
  end

  def show
    zip_code = ZipCode.new(value: params[:id])

    if not zip_code.valid?
      @address = Address.new
      redirect_to action: "index" and return
    end

    coords = Rails.cache.fetch zip_code.value, skip_nil: true, expires_in: 24.hours do
      results = Geocoder.search(zip_code.value)
      highest = GeocoderHelpers.highest_confidence(results)
      {lat: highest.latitude, lon: highest.longitude}
    end

    grid_url  = "https://api.weather.gov/points/#{coords[:lat]},#{coords[:lon]}"
    grid_resp = HTTParty.get(grid_url)
    grid_data = JSON.parse(grid_resp)
    forecast_url = grid_data["properties"]["forecast"]

      x = 1

  end
end
