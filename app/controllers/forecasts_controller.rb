require 'pry'

class ForecastsController < ApplicationController
  def index
    @address_form = AddressForm.new
  end

  def create
    @address_form = AddressForm.new(address: params[:address])

    if @address_form.valid?
      zip = Geocoder.search(@address_form.address).first.postal_code
      redirect_to action: "show", id: zip
    else
      render :index
    end
  end

  def show
    @address_form = AddressForm.new(address: params[:id])

    #if @address_form.valid?

 # else
 #   render :index
 # end
 #   coords = Geocoder.search
  end
end
