class PushNotification
  def initialize(tokens, body, customer_id)
    @tokens = tokens.compact
    @body = body
    @customer_id = customer_id
  end

  def send_messages
    mobile_client = Exponent::Push::Client.new
    @tokens.each do |token|
      message = {
        to: token,
        sound: 'default',
        body: @body,
        data: {
          customer_id: @customer_id,
        },
      }
      mobile_client.send_messages [message]
    rescue
      MobileToken.find_by_mobile_push_token(token)&.destroy
      next
    end
  end
end
