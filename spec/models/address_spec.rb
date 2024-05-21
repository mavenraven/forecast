require 'rails_helper'

RSpec.describe Address, type: :model do
  describe 'validations' do
    it "allows a valid address" do
      address = Address.new(value: "1 Apple Park Way, Cupertino, California")
      expect(address).to be_valid
    end

    it "allows a unicode address" do
      address = Address.new(value: "200 E. Santa Clara St. San José, California")
      expect(address).to be_valid
    end

    it "does not allow for <" do
      address = Address.new(value: "<")
      expect(address).to_not be_valid
    end

    it "does not allow for >" do
      address = Address.new(value: ">")
      expect(address).to_not be_valid
    end

    it "does not allow for ;" do
      address = Address.new(value: ";")
      expect(address).to_not be_valid
    end
  end
end
