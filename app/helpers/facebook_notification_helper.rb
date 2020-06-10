module FacebookNotificationHelper
  def self.broadcast_data(*args)
    retailer,
    retailer_users,
    message,
    assigned_agent = args

    total = retailer.facebook_unread_messages.size

    if message.present?
      serialized_message = ActiveModelSerializers::Adapter::Json.new(
        FacebookMessageSerializer.new(message)
      ).serializable_hash
    end

    retailer_users = retailer_users | retailer.admins

    customer = message&.customer || assigned_agent&.customer
    serialized_customer = ActiveModelSerializers::Adapter::Json.new(
      CustomerSerializer.new(customer)
    ).serializable_hash if customer.present?

    retailer_users.each do |ret_u|
      redis.publish 'new_message_counter', {identifier: '.item__cookie_facebook_messages', total:
        total, room: ret_u.id}.to_json

      if message.present?
        redis.publish 'message_facebook_chat', {facebook_message: serialized_message, room: ret_u.id}.to_json
        redis.publish 'customer_facebook_chat', {
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
            ret_u.retailer_admin == false
          )
        })
      end

      redis.publish 'customer_facebook_chat', customer_chat_args.to_json
    end
  end

  def self.redis
    @redis ||= Redis.new()
  end
end
