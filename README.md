# Forecasts

## Requirements
Forecasts is a small Rails app that I wrote for a take home interview. The requirements were:
1. The project must be completed in Ruby on Rails.
2. It accepts an address as input from the user.
3. Given the address, it displays the weather forecast data to the user.
   At minimum, this includes the current temperature, but could also include things like the high/low or extended forecast.
4. Cache the forecast details for 30 minutes for all subsequent requests by zip codes.
   Display indicator if result is pulled from cache. 

## Solution
My solution uses 2 pages. The index page has a form that accepts a free form
address. The form is then POSTed to `forecasts#create` for geocoding. If we can
successfully turn the address into a zip code, the user is redirected to `/<zip code>`.

## Live Demo
A demo can be seen at https://forecasts.onrender.com/. Note that this is using render's
hobby plan, so you may see a ~30 second "wake up" time.

## Code Architecture

`ForecastsController` is where the majority of the logic lives. A weather client and
helper module for geocoding live in `/lib`.

`Address` and `ZipCode` models exist as place to centralize validation concerns, but are
not persisted.

The business logic is tested primarily through request specs. `VCR` is used
for API stubbing.

`ActiveSupport::Cache::Store` is used for caching. In a real production app,
we would use ` ActiveSupport::Cache::RedisCacheStore` as the backing store.

I didn't use any service objects. If the controllers were more complex, I would have
split the logic out, but I felt that it's simple enough with the other helpers that were
created.

## Limitations and Future Enhancements

There are number of limitations and known issues:

* The chosen geocoding API doesn't work very well. For example, `34343` is mapped
  to Denver, but it's actually in Sarasota, FL. In a real project, I would use
  Google's geocoding API, but I didn't to use any service that required a credit
  card or have more of a surface area than just geocoding.

* Similarly, none of the free weather APIs that I tested were that great. The one
  that I settled on (`api.weather.gov`) doesn't offer the daily high / low, for example.

* I noticed some serious discrepancies in the weather returned by the API vs. Google. For example,
* last night in Brooklyn, `api.weather.gov` said that it was 63°, which Google said that it was 70°.
  
* The extended forecast is hardcoded placeholder values. This is possible to build with
  `api.weather.gov`, but I didn't have time to build this out.

* The forecast description from `api.weather.gov` can be as long as 8 words. I just
  use the first two words. An enhancement could be made to summarize the phrase instead.
  
* I was unable to get `resources: forecasts, path: '/'` working correctly with the
  path helpers.