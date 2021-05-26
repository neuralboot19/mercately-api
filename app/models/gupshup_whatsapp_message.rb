class GupshupWhatsappMessage < ApplicationRecord
  include BalanceConcern
  include AgentAssignmentConcern
  include WhatsappAutomaticAnswerConcern
  include WhatsappChatBotActionConcern
  include PushNotificationable
  include CustomerActiveWhatsappConcern

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
  after_save :retry_message, if: :saved_change_to_status?

  def type
    message_payload.try(:[], 'payload').try(:[], 'type') || message_payload['type']
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

    def retry_message
      return unless direction == 'outbound' && mexican_error?

      error = error_payload.try(:[], 'payload').try(:[], 'payload')
      return unless error.present? && error['code'].in?([1005, 1006, 1007, 1008]) && customer.number_to_use.present? &&
        customer.phone != customer.number_to_use && destination != customer.phone_number_to_use(false)

      msg_service = Whatsapp::Gupshup::V1::Outbound::Msg.new(retailer, customer)

      params = build_retry_params

      msg_service.send_message(type: params[:main_type], params: params, retailer_user: retailer_user, retry: true)
    end

    def mexican_error?
      return false unless status == 'error'

      country_id = customer.country_id
      if country_id.blank?
        parse_destination = Phonelib.parse(destination)
        country_id = parse_destination&.country
      end

      return false unless country_id == 'MX'
      return false unless error_payload.try(:[], 'payload').try(:[], 'payload').present?

      true
    end

    def build_retry_params
      case type
      when 'text'
        {
          message: message_payload['text'],
          type: message_payload['type'],
          gupshup_template_id: message_payload['id'],
          template_params: message_payload['params'],
          main_type: message_payload['isHSM'] == 'true' ? 'template' : 'text'
        }
      when 'file'
        {
          url: message_payload['url'],
          type: message_payload['type'],
          file_name: message_payload['filename'],
          caption: message_payload['caption'],
          template: message_payload['isHSM'],
          content_type: 'application/pdf',
          main_type: 'file'
        }
      when 'image'
        {
          url: message_payload['originalUrl'],
          type: message_payload['type'],
          caption: message_payload['caption'],
          content_type: 'image/',
          main_type: 'file'
        }
      when 'audio', 'voice'
        {
          url: message_payload['url'],
          type: message_payload['type'],
          main_type: 'file'
        }
      when 'video'
        {
          url: message_payload['url'],
          type: message_payload['type'],
          caption: message_payload['caption'],
          content_type: 'video/',
          main_type: 'file'
        }
      when 'location'
        {
          type: message_payload['type'],
          longitude: message_payload['longitude'],
          latitude: message_payload['latitude'],
          main_type: 'location'
        }
      end
    end
end
