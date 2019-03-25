class Retailer < ApplicationRecord
  has_one :meli_info
  has_many :products, dependent: :destroy
  has_many :customers, dependent: :destroy
  has_many :retailer_users, dependent: :destroy

  validates :name, presence: true
  validates :slug, uniqueness: true

  after_create :generate_slug

  def generate_slug
    if Retailer.find_by(['LOWER(name) LIKE ?', "%#{name.downcase}%"])
      update name: name << "-#{id}"
      update slug: name.parameterize << "-#{id}"
    else
      update slug: name.parameterize
    end
  end
end
