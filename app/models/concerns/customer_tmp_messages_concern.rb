module CustomerTmpMessagesConcern
  extend ActiveSupport::Concern

  included do
    after_commit :set_customer_tmp_messages, on: :create
  end

  private
    def set_customer_tmp_messages
      return unless customer.retailer.hs_sync_conversation? && customer.hs_active?

      tmp_messages = customer.tmp_messages
      tmp_message = {
        id: self.id,
        direction: message_direction,
        message_payload: message_info,
        created_at: self.created_at
      }

      tmp_messages << tmp_message
      customer.update!(tmp_messages: tmp_messages)
    end

    def message_direction
      case customer.channel
      when :whatsapp
        self.direction
      else
        self.sent_by_retailer ? 'outbound' : 'inbound'
      end
    end
end