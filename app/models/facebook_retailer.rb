class FacebookRetailer < ApplicationRecord
  belongs_to :retailer
  has_many :facebook_messages, dependent: :destroy
end
