class PushNotification
  def initialize(tokens, body)
    @tokens = tokens
    @body = body
  end

  def send_messages
    messages = []
    mobile_client = Exponent::Push::Client.new
    @tokens.each do |token|
      messages.push(
        to: token,
        sound: 'default',
        body: @body
      )
    end

    mobile_client.send_messages messages
  end
end
