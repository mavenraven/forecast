
module GeocoderHelpers
  # The geolocation API that we're using returns multiple results.
  # This method is a wrapper to grab the "best" one for use in the controllers, and cache it for later calls.
  def self.cached_best_result address
    Rails.cache.fetch address, skip_nil: true, expires_in: 30.minutes do
      results = Geocoder.search(address)
      GeocoderHelpers.filter_results(results)
    end
  end

  def self.filter_results results
    highest_confidence = nil
    results.each do |result|
      if result.instance_values["data"]["components"]["country_code"] != "us"
        next
      end
      if highest_confidence.nil?
        highest_confidence = result
      else
        if not result.instance_values["data"].nil? and not result.instance_values["data"]["confidence"].nil?
          if result.instance_values["data"]["confidence"] > highest_confidence.instance_values["data"]["confidence"]
            highest_confidence = result
          end
        end
      end
    end
    highest_confidence
  end
end