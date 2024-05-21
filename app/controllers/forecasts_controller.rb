require 'pry'

class ForecastsController < ApplicationController
  def index
    @address = Address.new
  end

  def create
    @address = Address.new(value: params[:address])

    if @address.valid?
      begin
        results = Geocoder.search(@address.value)
        highest = Utility.highest_confidence(results)
        if not highest.nil?
          redirect_to action: "show", id: highest.postal_code
        else
          #todo tests and add turn on error
          render :index
        end
      rescue
        #todo tests and add turn on error
        render :index
      end
    else
      render :index
    end
  end

  def show
    zip_code = ZipCode.new(value: params[:id])

    if zip_code.valid?
      coords = Rails.cache.fetch zip_code.value, expires_in: 24.hours do
        highest_confidence = nil
        Geocoder.search(zip_code.value).each do |result|
          if highest_confidence.nil?
            highest_confidence = result
          else
            if result.instance_values["data"]["confidence"] > highest_confidence.instance_values["data"]["confidence"]
              highest_confidence = result
            end
          end
        end
        x = 1



      end
    else
      @address = Address.new
      redirect_to action: "index"
    end
  end
end
