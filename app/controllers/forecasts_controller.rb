class ForecastsController < ApplicationController
  def index
  end

  def create
    address = params[:address_input]
    if address.match? /\A[\p{L}\p{N},.\s]+\z/u
      redirect_to(forecasts_show_path(95014))
    end
    # Geocoder.coordinates(pa)
  end

  def show
  end
end
