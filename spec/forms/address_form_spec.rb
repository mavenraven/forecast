require 'rails_helper'

RSpec.describe AddressForm, type: :model do
  describe 'validations' do
    it "allows a valid address" do
      form = AddressForm.new(address: "1 Apple Park Way, Cupertino, California")
      expect(form).to be_valid
    end

    it "allows a unicode address" do
      form = AddressForm.new(address: "200 E. Santa Clara St. San José, California")
      expect(form).to be_valid
    end

    it "does not allow for <" do
      form = AddressForm.new(address: "<")
      expect(form).to_not be_valid
    end

    it "does not allow for >" do
      form = AddressForm.new(address: ">")
      expect(form).to_not be_valid
    end

    it "does not allow for ;" do
      form = AddressForm.new(address: ";")
      expect(form).to_not be_valid
    end
  end
end
