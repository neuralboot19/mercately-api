class Retailer < ApplicationRecord
  require 'bcrypt'
  
  has_one :meli_retailer, dependent: :destroy
  has_one :retailer_user, dependent: :destroy
  has_one :facebook_retailer, dependent: :destroy
  has_one :payment_plan, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :customers, dependent: :destroy
  has_many :retailer_users, dependent: :destroy
  has_many :templates, dependent: :destroy
  has_many :karix_whatsapp_messages, dependent: :destroy
  has_many :karix_whatsapp_templates, dependent: :destroy

  validates :name, presence: true
  validates :slug, uniqueness: true

  after_save :generate_slug, if: :saved_change_to_name?
  after_create :save_free_plan

  enum id_type: %i[cedula pasaporte ruc]

  def facebook_unread_messages
    facebook_retailer&.facebook_unread_messages
  end

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

  def karix_unread_whatsapp_messages
    karix_whatsapp_messages.includes(:customer).where.not(status: 'read').where(direction: 'inbound', customers:
      { retailer_id: id })
  end

  def incomplete_meli_profile?
    id_number.blank? || address.blank? || city.blank? || state.blank?
  end

  def save_free_plan
    PaymentPlan.create(retailer: self)
  end

  def counter_karix_messages
    karix_whatsapp_messages.where(message_type: 'conversation').size
  end

  def counter_karix_notifications
    karix_whatsapp_messages.where(message_type: 'notification').size
  end

  def generate_api_key
    api_key = ''
    loop do
      api_key = SecureRandom.hex
      encripted_api_key = ::BCrypt::Password.create(api_key)
      break unless Retailer.find_by_encripted_api_key(encripted_api_key)
    end
    update_attributes(encripted_api_key: encripted_api_key, last_api_key_modified_date: Time.zone.now)
    api_key
  end

end
