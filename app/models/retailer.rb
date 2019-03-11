class Retailer < ApplicationRecord
  has_many :products, dependent: :destroy
  has_many :retailer_users, dependent: :destroy
end
