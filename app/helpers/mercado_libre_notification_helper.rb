module MercadoLibreNotificationHelper
  def self.broadcast_data(*args)
    retailer, retailer_users, type, action, quantity, object = args

    if type == 'questions'
      identifier = '#item__cookie_question'
      total = retailer.unread_questions.size
    elsif type == 'messages'
      identifier = '#item__cookie_message'
      total = retailer.unread_messages.size
    end

    customer = object&.customer
    retailer_users.each do |ret_u|
      redis.publish 'new_message_counter',
        {
          identifier: identifier,
          action: action,
          q: quantity,
          total: total,
          from: 'MercadoLibre',
          message_text: object&.question,
          customer_info: customer&.full_names.presence || customer&.meli_nickname,
          execute_alert: action == 'add',
          update_counter: false,
          type: type == 'messages' ? 'chats' : type,
          room: ret_u.id
        }.to_json
    end
  end

  def self.redis
    @redis ||= Redis.new(url: ENV['REDIS_PROVIDER'] || 'redis://localhost:6379/1')
  end
end
