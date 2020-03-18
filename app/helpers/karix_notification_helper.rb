module KarixNotificationHelper
  def self.ws_message_service
    Whatsapp::Karix::Messages.new
  end

  def self.broadcast_data(retailer, message = nil)
    total = retailer.karix_unread_whatsapp_messages.size
    redis.publish 'new_message_counter', {identifier: '.item__cookie_whatsapp_messages', total:
      total > 9 ? '9+' : total, room: retailer.id}.to_json

    if message.present?
      serialized_data = ActiveModelSerializers::Adapter::Json.new(
        KarixWhatsappMessageSerializer.new(message)
      ).serializable_hash
      redis.publish 'message_chat', {karix_whatsapp_message: serialized_data, room: retailer.id}.to_json

      serialized_data = ActiveModelSerializers::Adapter::Json.new(
        KarixCustomerSerializer.new(message.customer)
      ).serializable_hash
      redis.publish 'customer_chat', {customer: serialized_data, room: retailer.id}.to_json
    end
  end

  def self.redis
    @redis ||= Redis.new()
  end
end
