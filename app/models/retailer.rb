class Retailer < ApplicationRecord
  has_one :meli_info
  has_many :products, dependent: :destroy
  has_many :customers, dependent: :destroy
  has_many :retailer_users, dependent: :destroy

  validates :name, presence: true

  after_create :generate_slug

  def generate_slug
    downcased_name = name.downcase
    if Retailer.find_by(['LOWER(name) LIKE ?', "%#{downcased_name}%"])
      update name: name << "-#{id}"
      update slug: downcased_name.gsub(/\s/, '-') << "-#{id}"
    else
      update slug: downcased_name.gsub(/\s/, '-')
    end
  end
end
