module FacebookNotificationHelper
  def self.broadcast_data(retailer, retailer_users, message = nil)
    total = retailer.facebook_unread_messages.size

    if message.present?
      serialized_message = ActiveModelSerializers::Adapter::Json.new(
        FacebookMessageSerializer.new(message)
        ).serializable_hash
      serialized_customer = ActiveModelSerializers::Adapter::Json.new(
        CustomerSerializer.new(message.customer)
        ).serializable_hash
    end

    admin = retailer.admin
    exist_admin = retailer_users.any? { |u| u.id == admin.id }
    retailer_users << admin unless exist_admin

    retailer_users.each do |ret_u|
      redis.publish 'new_message_counter', {identifier: '.item__cookie_facebook_messages', total:
        total, room: ret_u.id}.to_json

      if message.present?
        redis.publish 'message_facebook_chat', {facebook_message: serialized_message, room: ret_u.id}.to_json
        redis.publish 'customer_facebook_chat', {customer: serialized_customer, room: ret_u.id}.to_json
      end
    end
  end

  def self.redis
    @redis ||= Redis.new()
  end
end
