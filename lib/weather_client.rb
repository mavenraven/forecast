
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
    result[:cached_at] = cached[:cached_at]
    result
  end
end
