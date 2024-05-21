# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GeocoderHelpers' do
  describe "best result" do
    context 'all results have a confidence' do
      it 'returns the highest confidence geocoded result' do
        result_class = Struct.new(:instance_values)

        results = [
          result_class.new({"data" => {"confidence" => 1, "components" => {"country_code" => "us"}}}),
          result_class.new({"data" => {"confidence" => 2, "components" => {"country_code" => "us"}}}),
          result_class.new({"data" => {"confidence" => 3, "components" => {"country_code" => "us"}}})
        ]
        expect(GeocoderHelpers.best_result(results)).to equal(results[2])
      end

      it 'ignores any non us results' do
        result_class = Struct.new(:instance_values)

        results = [
          result_class.new({"data" => {"confidence" => 1, "components" => {"country_code" => "us"}}}),
          result_class.new({"data" => {"confidence" => 2, "components" => {"country_code" => "us"}}}),
          result_class.new({"data" => {"confidence" => 3, "components" => {"country_code" => "us"}}}),
          result_class.new({"data" => {"confidence" => 9, "components" => {"country_code" => "es"}}})
        ]
        expect(GeocoderHelpers.best_result(results)).to equal(results[2])
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

        expect(GeocoderHelpers.best_result(results)).to equal(results[2])
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

        expect(GeocoderHelpers.best_result(results)).to equal(results[1])
      end
    end

    context 'when collection is empty' do
      it 'returns nil' do
        result_class = Struct.new(:instance_values)

        results = [
        ]

        expect{GeocoderHelpers.best_result(results)}.to raise_error ArgumentError
      end
    end
  end
end
