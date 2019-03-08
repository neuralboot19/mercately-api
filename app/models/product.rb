class Product < ApplicationRecord
  has_many :orders, dependent: :destroy
  belongs_to :retailer

  def ml_condition
    [ 'new', 'used', 'not_specified' ]
  end
end
