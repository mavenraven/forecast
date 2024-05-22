# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GeocoderHelpers' do
  describe "filter results" do
    context 'all results have a confidence' do
      it 'returns the highest confidence geocoded result' do
        result_class = Struct.new(:instance_values)

        results = [
          result_class.new({"data" => {"confidence" => 1, "components" => {"country_code" => "us"}}}),
          result_class.new({"data" => {"confidence" => 2, "components" => {"country_code" => "us"}}}),
          result_class.new({"data" => {"confidence" => 3, "components" => {"country_code" => "us"}}})
        ]
        expect(GeocoderHelpers.filter_results(results)).to equal(results[2])
      end

      it 'ignores any non us results' do
        result_class = Struct.new(:instance_values)

        results = [
          result_class.new({"data" => {"confidence" => 1, "components" => {"country_code" => "us"}}}),
          result_class.new({"data" => {"confidence" => 2, "components" => {"country_code" => "us"}}}),
          result_class.new({"data" => {"confidence" => 3, "components" => {"country_code" => "us"}}}),
          result_class.new({"data" => {"confidence" => 9, "components" => {"country_code" => "es"}}})
        ]
        expect(GeocoderHelpers.filter_results(results)).to equal(results[2])
      end
    end
    context 'not all results have a confidence' do
      it 'returns the highest confidence geocoded result' do
        result_class = Struct.new(:instance_values)

        results = [
          result_class.new({"data" => {"confidence" => 1, "components" => {"country_code" => "us"}}}),
          result_class.new({"data" => {"components" => {"country_code" => "us"}}}),
          result_class.new({"data" => {"confidence" => 3, "components" => {"country_code" => "us"}}})
        ]

        expect(GeocoderHelpers.filter_results(results)).to equal(results[2])
      end
    end

    context 'when there is a tie in confidence' do
      it 'returns the first of the tie' do
        result_class = Struct.new(:instance_values)

        results = [
          result_class.new({"data" => {"confidence" => 1, "components" => {"country_code" => "us"}}}),
          result_class.new({"data" => {"confidence" => 3, "components" => {"country_code" => "us"}}}),
          result_class.new({"data" => {"confidence" => 3, "components" => {"country_code" => "us"}}})
        ]

        expect(GeocoderHelpers.filter_results(results)).to equal(results[1])
      end
    end

    context 'when collection is empty' do
      it 'returns nil' do
        result_class = Struct.new(:instance_values)

        results = [
        ]

        expect(GeocoderHelpers.filter_results(results)).to eq(nil)
      end
    end
  end

  describe "cached best result" do
    it "happy path" do
      VCR.use_cassette("cached_best_result_happy_path") do
        result = GeocoderHelpers.cached_best_result "1 Apple Park Way. Cupertino, CA"
        expect(result.city).to eq("Cupertino")
      end

    end

    it "returns nil if no best result is available" do
      VCR.use_cassette("cached_best_result_none_available") do
        result = GeocoderHelpers.cached_best_result "sdfsdfsf"
        expect(result).to eq(nil)
      end
    end
  end
end
