class Retailer < ApplicationRecord
  include PhoneNumberConcern
  include TaggableConcern
  include AddSalesChannelConcern

  attr_encrypted :api_key,
                 mode: :per_attribute_iv_and_salt,
                 key: ENV['SECRET_KEY_BASE']

  has_one :meli_retailer, dependent: :destroy
  has_one :retailer_user, dependent: :destroy
  has_one :facebook_retailer, dependent: :destroy
  has_one :facebook_catalog, dependent: :destroy
  has_one :payment_plan, dependent: :destroy
  has_one_attached :avatar
  has_many :products, dependent: :destroy
  has_many :customers, dependent: :destroy
  has_many :customer_related_data, through: :customers
  has_many :retailer_users, dependent: :destroy
  has_many :templates, dependent: :destroy
  has_many :karix_whatsapp_messages, dependent: :destroy
  has_many :gupshup_whatsapp_messages, dependent: :destroy
  has_many :automatic_answers, dependent: :destroy
  has_many :payment_methods, dependent: :destroy
  has_many :paymentez_credit_cards, dependent: :destroy
  has_many :paymentez_transactions
  has_many :stripe_transactions
  has_many :funnels
  has_many :deals
  has_many :gs_templates, dependent: :destroy
  has_many :whatsapp_templates, dependent: :destroy
  has_many :top_ups, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :sales_channels, dependent: :destroy
  has_many :chat_bots, dependent: :destroy
  has_many :team_assignments, dependent: :destroy
  has_many :chat_bot_customers, through: :customers
  has_many :customer_related_fields
  has_many :calendar_events, dependent: :destroy
  has_many :reminders, dependent: :destroy
  has_many :contact_groups, dependent: :destroy
  has_many :campaigns, dependent: :destroy

  has_many :hubspot_fields
  has_many :customer_hubspot_fields

  validates :name, presence: true
  validates :slug, uniqueness: true

  before_validation :gupshup_src_name_to_nil
  before_create :format_phone_number
  before_save :set_ml_domain, if: :will_save_change_to_ml_site?
  after_create :save_free_plan
  after_create :send_to_mailchimp
  after_update :import_hubspot_properties, if: -> (obj) { obj.hubspot_integrated? && obj.hs_access_token_before_last_save.nil? }
  after_save :generate_slug, if: :saved_change_to_name?
  after_save :add_sales_channel
  after_save :update_gupshup_info, if: :saved_change_to_gupshup_src_name?

  validates :slug,
            exclusion: { in: %w(www),
            message: "%{value} is reserved." }

  enum id_type: %i[cedula pasaporte ruc rut otro]
  enum hubspot_match: %i[phone_or_email phone email], _prefix: true

  def facebook_unread_messages(retailer_user)
    facebook_retailer&.facebook_unread_messages(retailer_user)
  end

  def instagram_unread_messages(retailer_user)
    facebook_retailer&.instagram_unread_messages(retailer_user)
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
    return []

    messages = karix_whatsapp_messages.includes(:customer).where.not(status: 'read', account_uid: nil)
      .where(direction: 'inbound', customers: { retailer_id: id })
    return messages if retailer_user.admin? || retailer_user.supervisor?

    if retailer_user.only_assigned?
      messages.includes(customer: :agent_customer).where(agent_customers: { retailer_user_id: retailer_user.id })
    else
      messages.includes(customer: :agent_customer)
        .where(agent_customers: { retailer_user_id: [retailer_user.id, nil] })
    end
  end

  def gupshup_unread_whatsapp_messages(retailer_user)
    return []

    messages = gupshup_whatsapp_messages.includes(:customer).where.not(status: 'read', whatsapp_message_id: nil)
      .where(direction: 'inbound', customers: { retailer_id: id })
    return messages if retailer_user.admin? || retailer_user.supervisor?

    if retailer_user.only_assigned?
      messages.includes(customer: :agent_customer).where(agent_customers: { retailer_user_id: retailer_user.id })
    else
      messages.includes(customer: :agent_customer)
        .where(agent_customers: { retailer_user_id: [retailer_user.id, nil] })
    end
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
    retailer_users.where(removed_from_team: false, invitation_token: nil)
  end

  def admins
    retailer_users.where(retailer_admin: true)
  end

  def supervisors
    retailer_users.where(retailer_supervisor: true)
  end

  def positive_balance?(customer)
    return true if customer.is_chat_open?

    if karix_integrated?
      ws_balance >= ws_notification_cost
    elsif gupshup_integrated?
      ws_balance >= customer.ws_notification_cost
    end
  end

  def notification_messages
    karix_whatsapp_messages.notification_messages
  end

  def conversation_messages
    karix_whatsapp_messages.conversation_messages
  end

  def gupshup_temporal_messages
    GupshupTemporalMessageState.where(
      retailer_id: self.id
    ).order_by({event_timestamp: -1})
  end

  def whatsapp_phone_number(with_plus_sign=nil)
    self.phone_number(with_plus_sign)
  end

  def karix_integrated?
    whats_app_enabled? && karix_whatsapp_phone.present? &&
      karix_account_uid.present? && karix_account_token.present?
  end

  def gupshup_integrated?
    whats_app_enabled? &&
    gupshup_phone_number.present? &&
    gupshup_src_name.present?
  end

  def whatsapp_welcome_message
    automatic_answers.find_by(platform: :whatsapp, message_type: :new_customer, status: :active)
  end

  def whatsapp_inactive_message
    automatic_answers.find_by(platform: :whatsapp, message_type: :inactive_customer, status: :active)
  end

  def messenger_welcome_message
    automatic_answers.find_by(platform: :messenger, message_type: :new_customer, status: :active)
  end

  def messenger_inactive_message
    automatic_answers.find_by(platform: :messenger, message_type: :inactive_customer, status: :active)
  end

  def retailer_user_connected_to_fb
    retailer_users.where.not(uid: nil, provider: nil, facebook_access_token: nil).first
  end

  def whatsapp_integrated?
    karix_integrated? || gupshup_integrated?
  end

  def hubspot_integrated?
    hs_access_token.present?
  end

  def main_paymentez_credit_card
    self.paymentez_credit_cards.find_by_main(true)
  end

  def hs_properties
    hubspot.contact_properties.pluck('name')
  end

  def refund_message_cost(cost)
    update_column(:ws_balance, ws_balance + cost.to_f)
  end

  def create_funnel_steps
    return if funnels.exists?

    new_funnel = funnels.build(name: 'Negociaciones')
    new_funnel.funnel_steps.build(name: 'Calificado')
    new_funnel.funnel_steps.build(name: 'Contactado')
    new_funnel.funnel_steps.build(name: 'Demostración programada')
    new_funnel.funnel_steps.build(name: 'Propuesta enviada')
    new_funnel.funnel_steps.build(name: 'Negociación comenzada')
    new_funnel.save
  end

  def current_funnel
    funnels&.last
  end

  def update_gs_info
    update_gupshup_info
  end

  def send_failed_charge_email
    card_type = if ecu_charges
                  PaymentezCardHelper.brand(paymentez_credit_cards.last&.card_type)
                elsif int_charges
                  payment_methods.last&.card_type
                end

    recipients = RetailerUser.active(id).where(retailer_admin: true)
      .or(RetailerUser.active(id).where(retailer_supervisor: true))

    recipients.each do |r|
      RetailerMailer.failed_charge(self, r, card_type).deliver_now
    end
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

      self.retailer_number = '+593' + retailer_number[1, 9] if
        retailer_number.size == 10 && retailer_number[0] == '0'

      self.retailer_number = '+' + retailer_number if
        retailer_number.size == 12 && retailer_number[0,3] == '593'
    end

    def gupshup_src_name_to_nil
      self.gupshup_src_name = nil if gupshup_src_name.blank?
    end

    def import_hubspot_properties
      properties = hubspot.contact_properties.pluck('name', 'label', 'type').map do |name, label, type|
        { hubspot_field: name, hubspot_label: label, hubspot_type: type }
      end
      hubspot_fields.import(
        properties,
        validate: true,
        validate_with_context: :bulk_import,
        on_duplicate_key_update: {
          conflict_target: [:retailer_id, :hubspot_field]
        }
      )
    end

    def hubspot
      @hubspot = HubspotService::Api.new(hs_access_token)
    end

    def set_ml_domain
      self.ml_domain = case ml_site
                       when 'MLC'
                         'cl'
                       when 'MCR'
                         'co.cr'
                       else
                         'com.ec'
                       end
    end

    def update_gupshup_info
      if gupshup_src_name.blank?
        update(gupshup_app_id: nil, gupshup_app_token: nil)
      else
        aux_app_id = gs_service_api.set_app_id(gupshup_src_name)
        return unless aux_app_id.present?

        aux_app_token = gs_service_api.set_app_token(aux_app_id)
        update(gupshup_app_id: aux_app_id, gupshup_app_token: aux_app_token)
      end
    end

    def gs_service_api
      @gs_service_api ||= GupshupPartners::Api.new
    end
end
