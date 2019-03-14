class Customer < ApplicationRecord
  # validations
  validates :email, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  # relations
  has_many :orders, dependent: :destroy
  belongs_to :retailer
end
