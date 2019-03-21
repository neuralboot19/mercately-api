class Retailer < ApplicationRecord
  has_many :products, dependent: :destroy
  has_many :retailer_users, dependent: :destroy
  validates :name, presence: true

  def generate_slug
    update slug: name.gsub(/\s/, '-')
  end
end
