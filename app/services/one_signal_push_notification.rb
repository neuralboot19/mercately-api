class OneSignalPushNotification
  def initialize(emails, body, customer_id, channel)
    @emails = emails.compact
    @body = body
    @customer_id = customer_id
    @channel = channel
  end

  def send_messages
    customer = Customer.find(@customer_id)
    return unless customer.present?

    params = {
      "app_id" => ENV['ONE_SIGNAL_APP_ID'],
      "headings" => {"en" => customer.notification_info},
      "contents" => {"en" => @body},
      "data" => {
        "type": "message",
        "channel": @channel,
        "customer_id": @customer_id
      },
      "content_available" => true,
      "mutable_content" => true,
      "channel_for_external_user_ids" => "push",
      "include_external_user_ids" => @emails
    }

    uri = URI.parse('https://onesignal.com/api/v1/notifications')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path,
                                  'Content-Type'  => 'application/json;charset=utf-8',
                                  'Authorization' => "Basic #{ENV['ONE_SIGNAL_AUTH']}")
    request.body = params.as_json.to_json
    http.request(request)
  end
end