class ForecastsController < ApplicationController
  def index
    @address = Address.new
  end

  def create
    # Our address is input is free form, but if it looks like
    # a zip code, we can skip the geocode step completely.
    zip_code = ZipCode.new(value: params[:address])
    if zip_code.valid?
      redirect_to action: "show", id: zip_code.value and return
    end

    @address = Address.new(value: params[:address])

    # We check to make the sure the address only has human printable
    # characters to avoid any possible security weirdness around passing
    # untrusted input directly to a third party.
    if not @address.valid?
      render :index and return
    end

    # The address text wasn't a zip code, so we send it to the geocoding service.
    # If this fails for any reason, we bail at this point.
    begin
      best_result = GeocoderHelpers.cached_best_result @address.value
    rescue
      flash.now[:alert] = "Could not retrieve address."
      render :index and return
    end

    # Unfortunately, the geocoding API isn't great about consistently returning
    # data. If we get something without a zip code, we also bail.
    if best_result.nil? or best_result.postal_code.empty?
      flash.now[:alert] = "Address not found."
      render :index and return
    end

    redirect_to action: "show", id: best_result.postal_code
  end

  def show
    zip_code = ZipCode.new(value: params[:id])

    # If the user typed some random junk into their address bar, we just redirect to the index.
    if not zip_code.valid?
      @address = Address.new
      redirect_to action: "index" and return
    end

    # The weather API used only takes lat/lon, and not zip codes.
    # So before we can retrieve the weather, we need to convert our passed in
    # zip code into something it can work with.
    begin
      best_result = GeocoderHelpers.cached_best_result zip_code.value
    rescue
      flash.now[:alert] = "Could not retrieve location."
      render :show and return
    end

    # If we don't get back any results that can be used to pass to the weather API, we bail.
    if best_result.nil?
      flash.now[:alert] = "Could not retrieve location."
      render :show and return
    end

    # Finally grab the weather data. At last!
    begin
      @weather = WeatherClient.get_cached_weather_from_lat_lon best_result.latitude, best_result.longitude
    rescue
      flash.now[:alert] = "Could not retrieve weather."
      render :show and return
    end

    # This is needed because if we center the whole number, e.g. "-100", it will
    # optically look too far to the right.
    if @weather[:current_temp] < 0
      @is_negative = true
    end

    @location = best_result.city.nil? ? best_result.county : best_result.city
    @hi = @weather[:hi]
    @lo = @weather[:lo] ? @weather[:lo] : '-'
  end
end
