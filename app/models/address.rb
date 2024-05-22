class Address
  include ActiveModel::Model

  attr_accessor :value
  validates :value, presence: true, format: {with: /\A[\p{L}\p{N},.\s]*\z/u, message: 'contains invalid characters'}
end