class Retailer < ApplicationRecord
  has_many :products, dependent: :destroy
  has_many :retailer_owners, dependent: :destroy
end
