require 'pry'

class ForecastsController < ApplicationController
  def index
    @address_form = AddressForm.new
  end

  def create
    @address_form = AddressForm.new(address: params[:address])

    if @address_form.valid?
      throw 'hi'
    else
      render :index
    end
  end

  def show
  end
end
