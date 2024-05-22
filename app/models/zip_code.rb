class ZipCode
  include ActiveModel::Model

  attr_accessor :value
  validates :value, format: {with: /\A\p{N}{5}\z/u}
end
