class AddressForm
  include ActiveModel::Model

  attr_accessor :address

  validates :address, format: {with: /\A[\p{L}\p{N},.\s]*\z/u, message: 'contains invalid characters.'}
end