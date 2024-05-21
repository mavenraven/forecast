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
    @address = Address.new(value: params[:id])


    if
    Rails.cache.fetch()


    #if @address_form.valid?

 # else
 #   render :index
 # end
 #   coords = Geocoder.search
  end
end
