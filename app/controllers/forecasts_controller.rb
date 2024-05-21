require 'pry'

class ForecastsController < ApplicationController
  def index
    @address = Address.new
  end

  def create
    @address = Address.new(value: params[:address])

    if @address.valid?
      zip = Geocoder.search(@address.address).first.postal_code
      redirect_to action: "show", id: zip
    else
      render :index
    end
  end

  def show
    zip_code = ZipCode.new(value: params[:id])

    if zip_code.valid?
    else
      @address = Address.new
      redirect_to action: "index"
    end
  end
end
