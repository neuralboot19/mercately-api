module HsSyncConversationConcern
  extend ActiveSupport::Concern

  def sync_conversations
    return unless self.retailer.reload.hubspot_integrated?
    return unless self.retailer.reload.hs_sync_conversation?
    return unless self.hs_active

    messages = chat_messages
    return if messages.empty?

    title = hs_event_title
    hs = HubspotService::Api.new(self.retailer.hs_access_token)
    response = hs.sync_conversations(self.email, messages, title)

    return if response["status"].present? && response["status"] == "error"

    update_messages
  end

  def hs_event_title
    case self.channel
    when :whatsapp
      I18n.t('customer.sync_conversation.ws_conversations')
    when :messenger
      I18n.t('customer.sync_conversation.msn_conversations')
    else
      I18n.t('customer.sync_conversation.ig_conversations')
    end
  end

  def update_messages
    case self.channel
    when :whatsapp
      self.gupshup_whatsapp_messages.where(hs_sync: false).update_all(hs_sync: true)
    when :messenger
      self.facebook_messages.where(hs_sync: false).update_all(hs_sync: true)
    else
      self.instagram_messages.where(hs_sync: false).update_all(hs_sync: true)
    end
  end

  private

    def chat_messages
      messages = []

      case self.channel
      when :whatsapp
        self.gupshup_whatsapp_messages
        .where("status != ? AND hs_sync = ?", 0, false).order("created_at DESC").find_each  do |message|
          messages << hubspot_message_payload(message, 'whatsapp')
        end
      when :messenger
        self.facebook_messages
        .where("hs_sync = ?", false).order("created_at DESC").find_each  do |message|
          messages << hubspot_message_payload(message, 'messenger')
        end
      else
        self.instagram_messages
        .where("hs_sync = ?", false).order("created_at DESC").find_each  do |message|
          messages << hubspot_message_payload(message, 'instagram')
        end
      end

      messages
    end

    def hubspot_message_payload(message, platform)
      {
        "date": message.created_at.localtime.strftime("%d/%m/%Y, %I:%M%p"),
        "direction": direction(message, platform),
        "message": message.message_info
      }
    end

    def direction(message, platform)
      return "note" if message.note
      return platform == 'whatsapp' ? (message.direction == 'inbound'? 'in' : 'out') : (message.sent_by_retailer ? 'out' : 'in')
    end
end
