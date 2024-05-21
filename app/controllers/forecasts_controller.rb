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

    begin
      results = Geocoder.search(@address.value)
    rescue
      #todo tests and add turn on error
      render :index and return
    end

    highest = Utility.highest_confidence(results)

    if highest.nil?
      #todo tests and add turn on error
      render :index and return
    end

    redirect_to action: "show", id: highest.postal_code
  end

  def show
    zip_code = ZipCode.new(value: params[:id])

    if not zip_code.valid?
      @address = Address.new
      redirect_to action: "index" and return
    end

    coords = Rails.cache.fetch zip_code.value, skip_nil: true, expires_in: 24.hours do
      begin
        results = Geocoder.search(zip_code.value)
      rescue
        #TODO error message
        @address = Address.new
        redirect_to action: "index" and return
      end

      highest = Utility.highest_confidence(results)

      if highest.nil?
        #TODO error message
        @address = Address.new
        redirect_to action: "index" and return
      end

      {lat: highest.latitude, lon: highest.longitude}
    end

    if coords.nil?
      #TODO: error message
      redirect_to action: "index" and return
    end

    begin
      grid_url  = "https://api.weather.gov/points/#{coords[:lat]},#{coords[:lon]}"
      grid_resp = HTTParty.get(grid_url)
    rescue
      #TODO error message
      @address = Address.new
      redirect_to action: "index" and return
    end

    begin
      grid_data = JSON.parse(grid_resp)
    rescue
      #TODO error message
      @address = Address.new
      redirect_to action: "index" and return
    end

    if grid_data[:properties].nil? or grid_data

    end

      x = 1

  end
end
