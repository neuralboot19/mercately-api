class KarixWhatsappMessage < ApplicationRecord
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

  scope :range_between, -> (start_date, end_date) { where(created_at: start_date..end_date) }
  scope :notification_messages, -> { where(message_type: 'notification').where.not(status: 'failed') }
  scope :conversation_messages, -> { where(message_type: 'conversation').where.not(status: 'failed') }
  scope :unread, -> { where.not(status: 'read') }
  scope :sent, -> { where(status: 'sent') }
  scope :delivered, -> { where(status: 'delivered') }
  scope :read, -> { where(status: 'read') }

  after_create :apply_cost

  private

    def apply_cost
      self.cost = if status == 'failed'
                    retailer.refund_message_cost(cost)

                    0
                  else
                    retailer.send("ws_#{message_type}_cost")
                  end

      save
    end
end
