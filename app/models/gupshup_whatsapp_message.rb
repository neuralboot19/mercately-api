class GupshupWhatsappMessage < ApplicationRecord
  include StatusChatConcern
  include BalanceConcern
  include AgentAssignmentConcern
  include WhatsappAutomaticAnswerConcern
  include WhatsappChatBotActionConcern
  include PushNotificationable
  include CounterMessagesConcern
  include CustomerActiveWhatsappConcern
  include MessageSenderInformationConcern
  include RetryGupshupMessageConcern

  belongs_to :retailer
  belongs_to :customer
  belongs_to :campaign, required: false
  belongs_to :retailer_user, required: false
  has_one :reminder

  validates_presence_of :retailer, :customer, :status,
                        :direction, :source, :destination, :channel

  enum status: %w[error submitted enqueued sent delivered read]

  scope :range_between, -> (start_date, end_date) { where(created_at: start_date..end_date) }
  scope :inbound_messages, -> { where(direction: 'inbound') }
  scope :outbound_messages, -> { where(direction: 'outbound') }
  scope :notification_messages, -> { where(message_type: 'notification').where.not(status: 'error') }
  scope :conversation_messages, -> { where(message_type: 'conversation').where.not(status: 'error') }
  scope :unread, -> { where.not(status: 5) }
  scope :allowed_messages, -> do
    where("status <> 0 OR error_payload -> 'payload' -> 'payload' ->> 'code' = '1002'")
  end

  before_create :set_message_type
  after_save :apply_cost
  after_save :update_reminder
  after_save :notify_error_to_slack, if: :saved_change_to_status?

  def type
    message_payload.try(:[], 'payload').try(:[], 'type') || message_payload['type']
  end

  def has_referral?
    message_payload['payload'].try(:[], 'referral').present?
  end

  def has_referral_media?
    message_payload['payload'].try(:[], 'referral').try(:[], 'image').try(:[], 'id').present? ||
      message_payload['payload'].try(:[], 'referral').try(:[], 'video').try(:[], 'id').present?
  end

  def referral_media_id
    message_payload['payload'].try(:[], 'referral').try(:[], 'image').try(:[], 'id').presence ||
      message_payload['payload'].try(:[], 'referral').try(:[], 'video').try(:[], 'id')
  end

  def referral_type_media
    return 'image' if message_payload['payload'].try(:[], 'referral').try(:[], 'image').try(:[], 'id').present?

    'video'
  end

  def message_info
    case type
    when 'file'
      'Archivo'
    when 'image'
      'Imagen'
    when 'video'
      'Video'
    when 'audio', 'voice'
      'Audio'
    when 'location'
      'Ubicación'
    when 'contact'
      'Contacto'
    when 'sticker'
      'Sticker'
    else
      message_payload['payload'].try(:[], 'payload').try(:[], 'text') || message_payload['text']
    end
  end

  private

    def set_message_type
      return self.message_type = 'notification' if message_payload.try(:[], 'isHSM') == 'true'

      self.message_type = 'conversation'
    end

    def apply_cost
      if status == 'error' && (cost.blank? || !cost.zero?)
        retailer.refund_message_cost(cost)

        new_cost = 0
      end

      update_column(:cost, new_cost) if new_cost.present?
    end

    def update_reminder
      return unless reminder.present?

      reminder.failed! if status == 'error'
    end

    def notify_error_to_slack
      return unless mexican_error? && ENV['ENVIRONMENT'] == 'production'

      slack_client = Slack::Notifier.new ENV['SLACK_MSG_ERROR'], channel: '#ws-messages-errors'
      error = error_payload.try(:[], 'payload').try(:[], 'payload')

      slack_client.ping([
        "Retailer: (#{retailer.id}) #{retailer.name}",
        "Cliente: (#{customer.id}) #{customer.full_names.presence || customer.whatsapp_name}",
        "Teléfono destino: #{destination}",
        "ID del mensaje: #{id}",
        "Código del error: #{error['code']}",
        "Razón del error: #{error['reason']}"
      ].join("\n"))
    end
end
