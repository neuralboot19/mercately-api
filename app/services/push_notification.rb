class PushNotification
  def initialize(tokens, body, customer_id, channel)
    @tokens = tokens.compact
    @body = body
    @customer_id = customer_id
    @channel = channel
  end

  def send_messages
    fcm = FCM.new(ENV['FCM_KEY'])
    customer = Customer.find(@customer_id)
    return unless customer.present?

    notification = {
      data: {
        title: customer.notification_info,
        body: @body,
        customer_id: @customer_id,
        type: 'message',
        channel: @channel
      },
      priority: 'high',
      mutableContent: true,
      contentAvailable: true
    }

    fcm.send(@tokens, notification)
  end
end
