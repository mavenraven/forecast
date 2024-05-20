require 'rails_helper'
require 'pry'

RSpec.describe "Forecasts", type: :request do
  describe "GET index" do
    it "renders the index page" do
      get "/"
      expect(response.body).to include("Weather")
    end
  end
end
