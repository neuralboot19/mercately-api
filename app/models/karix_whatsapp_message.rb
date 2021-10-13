class KarixWhatsappMessage < ApplicationRecord
  include StatusChatConcern
  include ReactivateChatConcern
  include BalanceConcern
  include AgentAssignmentConcern
  include WhatsappAutomaticAnswerConcern
  include WhatsappChatBotActionConcern
  include PushNotificationable
  include CounterMessagesConcern
  include CustomerActiveWhatsappConcern
  include MessageSenderInformationConcern

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
  scope :inbound_messages, -> { where(direction: 'inbound') }
  scope :outbound_messages, -> { where(direction: 'outbound') }

  after_save :apply_cost

  def message_info
    return 'Archivo' if content_media_type == 'document'
    return 'Imagen' if content_media_type == 'image'
    return 'Video' if content_media_type == 'video'
    return 'Audio' if ['audio', 'voice'].include?(content_media_type)
    return 'Ubicación' if content_type == 'location'
    return 'Contacto' if content_type == 'contact'
    return 'Sticker' if content_type == 'sticker'

    content_text
  end

  private

    def apply_cost
      if status == 'failed' && (cost.blank? || !cost.zero?)
        retailer.refund_message_cost(cost)

        new_cost = 0
      end

      update_column(:cost, new_cost) if new_cost.present?
    end
end
