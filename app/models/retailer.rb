class Retailer < ApplicationRecord
  has_one :meli_info
  has_many :products, dependent: :destroy
  has_many :customers, dependent: :destroy
  has_many :retailer_users, dependent: :destroy

  validates :name, presence: true
  validates :slug, uniqueness: true

  after_create :generate_slug

  def to_param
    slug
  end

  def generate_slug
    if Retailer.where(['LOWER(name) LIKE ?', "%#{name.downcase}%"]).where.not(id: id).count.positive?
      update slug: name.parameterize << "-#{id}"
      update name: name << "-#{id}"
    else
      update slug: name.parameterize
    end
  end
end
