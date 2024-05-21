require 'rails_helper'

RSpec.describe ZipCode, type: :model do
  describe 'validations' do
    it "allows a valid zip code" do
      zip_code = ZipCode.new(value: "11201")
      expect(zip_code).to be_valid
    end

    it "does not allow for 'full' zip codes" do
      zip_code = ZipCode.new(value: "11201-1234")
      expect(zip_code).to_not be_valid
    end

    it "does not allow for words" do
      zip_code = ZipCode.new(value: "hello")
      expect(zip_code).to_not be_valid
    end

    it "does not allow for blank" do
      zip_code = ZipCode.new(value: "")
      expect(zip_code).to_not be_valid
    end
  end
end
