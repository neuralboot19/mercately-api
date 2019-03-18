class Retailer < ApplicationRecord
  validates :name, presence: true
  has_many :products, dependent: :destroy
  has_many :retailer_users, dependent: :destroy

  def generate_slug
    update slug: name.gsub(/\s/, '-')
  end
end
