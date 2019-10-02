class Retailer < ApplicationRecord
  has_one :meli_retailer, dependent: :destroy
  has_one :retailer_user, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :customers, dependent: :destroy
  has_many :retailer_users, dependent: :destroy
  has_many :templates, dependent: :destroy

  validates :name, presence: true
  validates :slug, uniqueness: true
  after_save :generate_slug, if: :saved_change_to_name?

  enum id_type: %i[cedula pasaporte ruc]

  def to_param
    slug
  end

  def generate_slug
    update slug: if Retailer.where('LOWER(name) LIKE ?', "%#{name.downcase}%").where.not(id: id).count.positive?
                   "#{name}-#{id}".parameterize
                 else
                   name.parameterize
                 end
  end

  # Actualiza el token de ML si esta a punto de vencer
  def update_meli_access_token
    return if meli_retailer.meli_token_updated_at.to_i > (DateTime.current - 4.hours).to_i

    MercadoLibre::Auth.new(self).refresh_access_token
  end

  def unread_messages
    Message.includes(:customer).where(date_read: nil, answer: nil, customers: { retailer_id: id })
  end

  def unread_questions
    Question.includes(:customer).where(date_read: nil, customers: { retailer_id: id })
  end
end
