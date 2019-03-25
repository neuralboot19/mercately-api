class Retailer < ApplicationRecord
  has_many :products, dependent: :destroy
  has_many :customers, dependent: :destroy
  has_many :retailer_users, dependent: :destroy
  has_one :meli_info
  validates :name, presence: true

  def to_param
    slug
  end

  def generate_slug
    update slug: name.gsub(/\s/, '-')
  end
end
