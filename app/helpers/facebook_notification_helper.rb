module FacebookNotificationHelper
  def self.broadcast_data(*args)
    retailer,
    retailer_users,
    message,
    assigned_agent,
    customer,
    platform = args

    platform = 'facebook' if platform.nil? || platform == 'messenger'
    if message.present?
      serialized_message = ActiveModelSerializers::Adapter::Json.new(
        FacebookMessageSerializer.new(message)
      ).serializable_hash
    end

    retailer_users = retailer_users | retailer.admins | retailer.supervisors

    customer = message&.customer || assigned_agent&.customer || customer
    if customer.present?
      serialized_customer = ActiveModelSerializers::Adapter::Json.new(
        CustomerSerializer.new(customer)
      ).serializable_hash
    end

    retailer_users.each do |ret_u|
      removed_agent = false
      if platform == 'instagram'
        unread_messages = ret_u.instagram_unread
        unread_chats_count = ret_u.unread_instagram_chats_count
      else
        unread_messages = ret_u.messenger_unread
        unread_chats_count = ret_u.unread_messenger_chats_count
      end

      if ret_u.agent? && ret_u.only_assigned?
        removed_agent = is_removed(ret_u, assigned_agent)
        add_agent = assigned_agent.present? && assigned_agent.persisted? && assigned_agent.retailer_user_id == ret_u.id

        next if !removed_agent && !add_agent
      end

      redis.publish 'new_message_counter', {
        identifier: ".item__cookie_#{platform}_messages",
        unread_messages: unread_messages,
        unread_chats_count: unread_chats_count,
        from: platform == 'instagram' ? 'Instagram' : 'Messenger',
        message_text: message_info(message),
        customer_info: customer&.full_names.presence || '',
        execute_alert: message.present? ? !message.sent_from_mercately : false,
        room: ret_u.id
      }.to_json

      if message.present?
        redis.publish "message_#{platform}_chat", { facebook_message: serialized_message, room: ret_u.id }.to_json
        redis.publish "customer_#{platform}_chat", {
          customer: serialized_customer,
          room: ret_u.id
        }.to_json
      end

      customer_chat_args = {
        customer: serialized_customer,
        room: ret_u.id
      }

      if assigned_agent.present?
        customer_chat_args.merge!({
          remove_only: (
            assigned_agent.persisted? &&
            assigned_agent.retailer_user_id != ret_u.id &&
            ret_u.admin? == false &&
            ret_u.supervisor? == false
          ) || removed_agent
        })
      end

      redis.publish "customer_#{platform}_chat", customer_chat_args.to_json
    end
  end

  def self.redis
    @redis ||= Redis.new(url: ENV['REDIS_PROVIDER'] || 'redis://localhost:6379/1')
  end

  def self.message_info(message)
    return '' unless message.present?

    case message.file_type
    when 'file'
      'Archivo'
    when 'image'
      'Imagen'
    when 'video'
      'Video'
    when 'audio', 'voice'
      'Audio'
    when 'location'
      'Ubicación'
    when 'fallback'
      'Publicación'
    else
      message.text
    end
  end

  def self.is_removed(ret_u, assigned_agent)
    assigned_agent.present? && ((!assigned_agent.persisted? &&
      assigned_agent.retailer_user_id == ret_u.id) || (assigned_agent.persisted? &&
      assigned_agent.retailer_user_id != ret_u.id))
  end
end
