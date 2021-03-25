class GupshupWhatsappMessage < ApplicationRecord
  include BalanceConcern
  include AgentAssignmentConcern
  include WhatsappAutomaticAnswerConcern
  include WhatsappChatBotActionConcern
  include PushNotificationable

  belongs_to :retailer
  belongs_to :customer
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

  private

    def set_message_type
      return self.message_type = 'notification' if message_payload.try(:[], 'isHSM') == 'true'

      self.message_type = 'conversation'
    end

    def apply_cost
      aux_cost = cost.present? ? cost : 0

      new_cost = if status != 'error' && aux_cost.zero?
                   customer.send("ws_#{message_type}_cost")
                 elsif status == 'error' && !aux_cost.zero?
                   0
                 end

      update_column(:cost, new_cost) if new_cost.present?
    end

    def update_reminder
      return unless reminder.present?

      reminder.failed! if status == 'error'
    end

    def notify_error_to_slack
      return unless status == 'error' && error_payload.present? && ENV['ENVIRONMENT'] == 'production'

      country_id = customer.country_id
      if country_id.blank?
        parse_destination = Phonelib.parse(destination)
        country_id = parse_destination&.country
      end

      return unless country_id == 'MX'

      payload = error_payload.try(:[], 'payload').try(:[], 'payload')
      return unless payload.present?

      slack_client = Slack::Notifier.new ENV['SLACK_MSG_ERROR'], channel: '#ws-messages-errors'

      slack_client.ping([
        "Retailer: (#{retailer.id}) #{retailer.name}",
        "Cliente: (#{customer.id}) #{customer.full_names.presence || customer.whatsapp_name}",
        "Teléfono destino: #{destination}",
        "ID del mensaje: #{id}",
        "Código del error: #{payload['code']}",
        "Razón del error: #{payload['reason']}"
      ].join("\n"))
    end
end
