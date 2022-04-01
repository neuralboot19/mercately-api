module AgentNotificationHelper
  def self.notify_agent(agent_customer, chat_type)
    return unless agent_customer.present?

    agent_notification = AgentNotification.new do |notification|
      notification.customer_id = agent_customer.customer.id
      notification.retailer_user_id = agent_customer.retailer_user.id
      notification.notification_type = chat_type
    end

    return unless agent_notification.save

    redis.publish 'agent_assignment',
                  {
                    id: agent_notification.id,
                    notification_type: chat_type,
                    customer: serialize_customer(agent_customer.customer, chat_type),
                    created_at: agent_notification.created_at,
                    room: agent_customer.retailer_user.id
                  }.to_json
  end

  def self.redis
    @redis ||= Redis.new(url: ENV['REDIS_PROVIDER'] || 'redis://localhost:6379/1')
  end

  def self.serialize_customer(customer, chat_type)
    case chat_type
    when 'messenger', 'facebook', 'instagram'
      ActiveModelSerializers::Adapter::Json.new(
        CustomerSerializer.new(customer)
      ).serializable_hash
    when 'whatsapp'
      ActiveModelSerializers::Adapter::Json.new(
        GupshupCustomerSerializer.new(customer)
      ).serializable_hash
    else
      raise StandardError, 'Chat type not valid for notification'
    end
  end

  private_class_method :redis, :serialize_customer
end
