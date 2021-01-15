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

  before_create :set_message_type
  after_save :apply_cost
  after_save :update_reminder

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

      reminder.update(status: :failed) if status == 'error'
    end
end
