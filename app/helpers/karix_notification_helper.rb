module KarixNotificationHelper
  def self.ws_message_service
    Whatsapp::Karix::Messages.new
  end

  def self.broadcast_data(retailer, retailer_users, message = nil, assigned_agent = nil)
    if message.present?
      serialized_message = ActiveModelSerializers::Adapter::Json.new(
        KarixWhatsappMessageSerializer.new(message)
        ).serializable_hash
      serialized_customer = ActiveModelSerializers::Adapter::Json.new(
        KarixCustomerSerializer.new(message.customer)
        ).serializable_hash
    end

    admin = retailer.admin
    exist_admin = retailer_users.any? { |u| u.id == admin.id }
    retailer_users << admin unless exist_admin

    retailer_users.each do |ret_u|
      total = retailer.karix_unread_whatsapp_messages(ret_u).size

      redis.publish 'new_message_counter', {identifier: '.item__cookie_whatsapp_messages', total:
        total > 9 ? '9+' : total, room: ret_u.id}.to_json

      if message.present?
        redis.publish 'message_chat', {karix_whatsapp_message: serialized_message, room: ret_u.id}.to_json
        redis.publish 'customer_chat', {customer: serialized_customer, room: ret_u.id}.to_json
      end

      if assigned_agent.present?
        redis.publish 'customer_chat', {customer: serialized_agent_customer(assigned_agent.customer), remove_only:
          (assigned_agent.persisted? && assigned_agent.retailer_user_id != ret_u.id &&
          ret_u.retailer_admin == false), room: ret_u.id}.to_json
      end
    end
  end

  def self.serialized_agent_customer(customer)
    ActiveModelSerializers::Adapter::Json.new(
      KarixCustomerSerializer.new(customer)
      ).serializable_hash
  end

  def self.redis
    @redis ||= Redis.new()
  end
end
