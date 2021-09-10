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
      unread_messages = if platform == 'instagram'
                          ret_u.instagram_unread
                        else
                          ret_u.messenger_unread
                        end

      if ret_u.agent? && ret_u.only_assigned?
        removed_agent = is_removed(ret_u, assigned_agent)
        add_agent = assigned_agent.present? && assigned_agent.persisted? && assigned_agent.retailer_user_id == ret_u.id

        next if !removed_agent && !add_agent
      end

      redis.publish 'new_message_counter', {
        identifier: ".item__cookie_#{platform}_messages",
        unread_messages: unread_messages,
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

    return 'Archivo' if message.file_type == 'file'
    return 'Imagen' if message.file_type == 'image'
    return 'Video' if message.file_type == 'video'
    return 'Audio' if ['audio', 'voice'].include?(message.file_type)
    return 'Ubicación' if message.file_type == 'location'
    message.text
  end

  def self.is_removed(ret_u, assigned_agent)
    assigned_agent.present? && ((!assigned_agent.persisted? &&
      assigned_agent.retailer_user_id == ret_u.id) || (assigned_agent.persisted? &&
      assigned_agent.retailer_user_id != ret_u.id))
  end
end
