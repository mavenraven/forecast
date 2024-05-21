# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GeocoderHelpers' do
  describe "highest_confidence" do
    context 'all results have a confidence' do
      it 'returns the highest confidence geocoded result' do
        result_class = Struct.new(:instance_values)

        results = [
          result_class.new({"data" => {"confidence" => 1}}),
          result_class.new({"data" => {"confidence" => 2}}),
          result_class.new({"data" => {"confidence" => 3}})
        ]

        expect(GeocoderHelpers.highest_confidence(results)).to equal(results[2])
      end


    end
    context 'not all results have a confidence' do
      it 'returns the highest confidence geocoded result' do
        result_class = Struct.new(:instance_values)

        results = [
          result_class.new({"data" => {"confidence" => 1}}),
          result_class.new({"data" => {}}),
          result_class.new({"data" => {"confidence" => 3}})
        ]

        expect(GeocoderHelpers.highest_confidence(results)).to equal(results[2])
      end
    end

    context 'when there is a tie in confidence' do
      it 'returns the first of the tie' do
        result_class = Struct.new(:instance_values)

        results = [
          result_class.new({"data" => {"confidence" => 1}}),
          result_class.new({"data" => {"confidence" => 3}}),
          result_class.new({"data" => {"confidence" => 3}})
        ]

        expect(GeocoderHelpers.highest_confidence(results)).to equal(results[1])
      end
    end

    context 'when collection is empty' do
      it 'returns nil' do
        result_class = Struct.new(:instance_values)

        results = [
        ]

        expect{GeocoderHelpers.highest_confidence(results)}.to raise_error ArgumentError
      end
    end
  end
end
