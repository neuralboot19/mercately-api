class Customer < ApplicationRecord
  belongs_to :retailer
  has_many :orders, dependent: :destroy

  validates :email, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
end
