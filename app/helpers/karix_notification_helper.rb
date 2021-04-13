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

    customer = message&.customer || assigned_agent&.customer || customer
    serialized_customer = ActiveModelSerializers::Adapter::Json.new(
      KarixCustomerSerializer.new(customer)
    ).serializable_hash if customer

    retailer_users = retailer_users | retailer.admins | retailer.supervisors

    retailer_users.each do |ret_u|
      removed_agent = false

      if ret_u.agent? && ret_u.only_assigned?
        removed_agent = (!assigned_agent.persisted? && assigned_agent.retailer_user_id == ret_u.id) ||
          (assigned_agent.persisted? && assigned_agent.retailer_user_id != ret_u.id)
        add_agent = assigned_agent.persisted? && assigned_agent.retailer_user_id == ret_u.id

        next if !removed_agent && !add_agent
      end

      total = retailer.karix_unread_whatsapp_messages(ret_u).size

      redis.publish 'new_message_counter',
                    {
                      identifier: '.item__cookie_whatsapp_messages',
                      total: total,
                      from: 'WhatsApp',
                      message_text: message_info(message),
                      customer_info: customer&.notification_info,
                      execute_alert: message.present? ? message.direction == 'inbound' : false,
                      update_counter: message.blank? || message.direction == 'inbound',
                      room: ret_u.id
                    }.to_json

      if message.present?
        redis.publish 'message_chat',
                      {
                        karix_whatsapp_message: serialized_message,
                        room: ret_u.id
                      }.to_json
      end

      if customer
        remove = customer.agent.present? ? (
          customer.persisted? &&
          customer&.agent&.id != ret_u.id &&
          ret_u.admin? == false &&
          ret_u.supervisor? == false
        ) : false
        customer_chat_args = {
          customer: serialized_customer,
          remove_only: remove || removed_agent,
          room: ret_u.id
        }
        redis.publish 'customer_chat', customer_chat_args.to_json
      end
      if assigned_agent.present?
        customer_chat_args = {
          customer: serialized_agent_customer(assigned_agent.customer),
          remove_only: (
            assigned_agent.persisted? &&
            assigned_agent.retailer_user_id != ret_u.id &&
            ret_u.admin? == false &&
            ret_u.supervisor? == false
          ) || removed_agent,
          room: ret_u.id,
          recent_inbound_message_date: message&.customer&.recent_inbound_message_date
        }.to_json

        redis.publish 'customer_chat', customer_chat_args.to_json
      end
    end
  end

  def self.serialized_agent_customer(customer)
    ActiveModelSerializers::Adapter::Json.new(
      KarixCustomerSerializer.new(customer)
      ).serializable_hash
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
    return 'Ubicación' if message.content_type == 'location'
    return 'Contacto' if message.content_type == 'contact'
    return 'Sticker' if message.content_type == 'sticker'
    message.content_text
  end
end
