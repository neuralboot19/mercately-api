class Retailer < ApplicationRecord
  attr_encrypted :api_key,
                 mode: :per_attribute_iv_and_salt,
                 key: ENV['SECRET_KEY_BASE']

  has_one :meli_retailer, dependent: :destroy
  has_one :retailer_user, dependent: :destroy
  has_one :facebook_retailer, dependent: :destroy
  has_one :payment_plan, dependent: :destroy
  has_one_attached :avatar
  has_many :products, dependent: :destroy
  has_many :customers, dependent: :destroy
  has_many :retailer_users, dependent: :destroy
  has_many :templates, dependent: :destroy
  has_many :karix_whatsapp_messages, dependent: :destroy
  has_many :karix_whatsapp_templates, dependent: :destroy
  has_many :top_ups, dependent: :destroy

  validates :name, presence: true
  validates :slug, uniqueness: true

  after_save :generate_slug, if: :saved_change_to_name?
  after_create :save_free_plan
  after_create :send_to_mailchimp
  before_create :format_phone_number
  after_create :send_welcome_ws

  validates :slug,
            exclusion: { in: %w(www),
            message: "%{value} is reserved." }

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

  def karix_unread_whatsapp_messages(retailer_user)
    messages = karix_whatsapp_messages.includes(:customer).where.not(status: 'read', account_uid: nil)
      .where(direction: 'inbound', customers: { retailer_id: id })
    return messages if retailer_user.admin?

    customer_ids = messages.pluck(:customer_id).compact
    remove_customer_ids = AgentCustomer.where(customer_id: customer_ids).where.not(retailer_user_id: retailer_user.id)
      .pluck(:customer_id).compact
    customer_ids -= remove_customer_ids

    messages.where(customer_id: customer_ids)
  end

  def incomplete_meli_profile?
    id_number.blank? || address.blank? || city.blank? || state.blank?
  end

  def counter_karix_messages
    karix_whatsapp_messages.where(message_type: 'conversation').size
  end

  def counter_karix_notifications
    karix_whatsapp_messages.where(message_type: 'notification').size
  end

  def generate_api_key
    api_key = SecureRandom.hex
    update_attributes(api_key: api_key, last_api_key_modified_date: Time.zone.now)

    api_key
  end

  def public_phone_number
    karix_whatsapp_phone || phone_number
  end

  def team_agents
    retailer_users.where(removed_from_team: false).where.not(invitation_accepted_at: nil) +
      retailer_users.where(retailer_admin: true)
  end

  def admin
    retailer_users.find_by(retailer_admin: true)
  end

  def positive_balance?
    ws_balance >= 0.0672
  end

  private

    def save_free_plan
      PaymentPlan.create(retailer: self)
    end

    def send_to_mailchimp
      Retailers::ListOnMailchimpJob.perform_later(id) if persisted? && ENV['ENVIRONMENT'] == 'production'
    end

    def format_phone_number
      return unless retailer_number.present?

      self.retailer_number = '+593' + retailer_number[1,9] if
        retailer_number.size == 10 && retailer_number[0] == '0'

      self.retailer_number = '+' + retailer_number if
        retailer_number.size == 12 && retailer_number[0,3] == '593'
    end

    def send_welcome_ws
      return unless retailer_number.present? && retailer_number[0] == '+' && ENV['ENVIRONMENT'] == 'production'

      response = ws_message_service.send_welcome_message(self)

      unless response['error'].present?
        sender = Retailer.find_by(karix_whatsapp_phone: '+593989083446')
        message = sender.karix_whatsapp_messages.find_or_initialize_by(uid: response['objects'][0]['uid'])
        message = ws_message_service.assign_message(message, sender, response['objects'][0])
        message.save
      end
    end

    def ws_message_service
      @ws_message_service = Whatsapp::Karix::Messages.new
    end
end
