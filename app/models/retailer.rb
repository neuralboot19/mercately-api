class Retailer < ApplicationRecord
  has_one :meli_retailer, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :customers, dependent: :destroy
  has_many :retailer_users, dependent: :destroy
  validates :name, presence: true
  validates :slug, uniqueness: true
  enum id_type: [:cedula, :pasaporte, :ruc]
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

  def update_meli_access_token
    MercadoLibre::Auth.new(self).refresh_access_token
  end

  def connected_to_ml?
    meli_retailer.present?
  end
end
