
module WeatherClient
  def self.get_cached_weather_from_lat_lon lat, lon
    key = {lat: lat, lon: lon}
    cached = Rails.cache.fetch key, skip_nil: true, expires_in: 30.minutes do
      grid_url  = "https://api.weather.gov/points/#{lat},#{lon}"
      grid_resp = HTTParty.get(grid_url)
      grid_data = JSON.parse(grid_resp)
      forecast_url = grid_data["properties"]["forecastHourly"]

      forecast_resp = HTTParty.get(forecast_url)
      {forecast_data: JSON.parse(forecast_resp), cached_at: Time.now}
    end

    result = {}
    result[:current_temp] = cached[:forecast_data]["properties"]["periods"][0]["temperature"]
    # Forecasts can come in as 'Chance Showers And Thunderstorms then Partly Cloudy', which isn't great for the UI layout.
    # TODO: better logic
    result[:forecast] = cached[:forecast_data]["properties"]["periods"][0]["shortForecast"].split[0..1].join(' ')
    hi_lo = calculate_hi_lo cached[:forecast_data]["properties"]["periods"]

    result[:hi] = hi_lo[:hi]
    result[:lo] = hi_lo[:lo]

    result[:cached_at] = cached[:cached_at]
    result
  end

  def self.calculate_hi_lo temps
    if temps[0]["isDaytime"]
      state = :started_during_day_time
    else
      state = :started_during_night_time
    end

    hi = nil
    lo = nil

    temps.each_with_index do |temp, i|
      if state == :started_during_day_time and i == 0
          hi = temp["temperature"]

      elsif state == :started_during_day_time and temp["isDaytime"]
        hi = temp["temperature"] > hi ? temp["temperature"] : hi

      elsif state == :started_during_day_time and not temp["isDaytime"]
        state = :became_night_time
        lo = temp["temperature"]

      elsif state == :became_night_time and not temp["isDaytime"]
        lo = temp["temperature"] < lo ? temp["temperature"] : lo

      elsif state == :became_night_time and temp["isDaytime"]
        break

      elsif state == :started_during_night_time and i == 0
        lo = temp["temperature"]

      elsif state == :started_during_night_time and not temp["isDaytime"]
        lo = temp["temperature"] < lo ? temp["temperature"] : lo

      elsif state == :started_during_night_time and temp["isDaytime"]
        break
      end
    end

    {hi: hi, lo: lo}
  end
end
