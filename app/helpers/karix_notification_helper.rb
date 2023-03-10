module KarixNotificationHelper
  def self.ws_message_service
    Whatsapp::Karix::Messages.new
  end

  def self.broadcast_data(*args)
    # Set all local vars
    retailer,
    retailer_users,
    message,
    assigned_agent,
    customer = args

    if message.present?
      serialized_message = ActiveModelSerializers::Adapter::Json.new(
        KarixWhatsappMessageSerializer.new(message)
        ).serializable_hash
    end

    customer = customer || message&.customer || assigned_agent&.customer
    serialized_customer = ActiveModelSerializers::Adapter::Json.new(
      KarixCustomerSerializer.new(customer)
    ).serializable_hash if customer

    retailer_users = retailer_users | retailer.admins | retailer.supervisors

    retailer_users.each do |ret_u|
      redis.publish 'new_message_counter',
                    {
                      identifier: '.item__cookie_whatsapp_messages',
                      unread_messages: ret_u.whatsapp_unread,
                      unread_chats_count: ret_u.unread_whatsapp_chats_count,
                      from: 'WhatsApp',
                      message_text: message_info(message),
                      customer_info: customer&.notification_info,
                      execute_alert: message.present? ? message.direction == 'inbound' : false,
                      room: ret_u.id
                    }.to_json

      if message.present?
        redis.publish 'message_chat',
                      {
                        karix_whatsapp_message: serialized_message,
                        room: ret_u.id
                      }.to_json
      end

      next unless customer

      customer_chat_args = {
        customer: serialized_customer,
        remove_only: ret_u.remove_agent?(assigned_agent),
        room: ret_u.id,
        recent_inbound_message_date: customer.recent_inbound_message_date
      }

      redis.publish 'customer_chat', customer_chat_args.to_json
    end
  end

  def self.redis
    @redis ||= Redis.new(url: ENV['REDIS_PROVIDER'] || 'redis://localhost:6379/1')
  end

  def self.message_info(message)
    return '' unless message.present?

    return 'Archivo' if message.content_media_type == 'document'
    return 'Imagen' if message.content_media_type == 'image'
    return 'Video' if message.content_media_type == 'video'
    return 'Audio' if ['audio', 'voice'].include?(message.content_media_type)
    return 'Ubicaci??n' if message.content_type == 'location'
    return 'Contacto' if message.content_type == 'contact'
    return 'Sticker' if message.content_type == 'sticker'
    message.content_text
  end
end
