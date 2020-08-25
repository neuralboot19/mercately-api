class PushNotification
  def initialize(tokens, body)
    @tokens = tokens.uniq
    @body = body
  end

  def send_messages
    mobile_client = Exponent::Push::Client.new
    @tokens.each do |token|
      message = {
        to: token,
        sound: 'default',
        body: @body
      }
      mobile_client.send_messages message
    rescue
      MobileToken.find_by_mobile_push_token(token)&.destroy
      next
    end
  end
end
