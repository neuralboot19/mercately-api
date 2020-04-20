module MercadoLibreNotificationHelper
  def self.broadcast_data(retailer, retailer_users, type, action, quantity)
    if type == 'questions'
      identifier = '#item__cookie_question'
      total = retailer.unread_questions.size
    elsif type == 'messages'
      identifier = '#item__cookie_message'
      total = retailer.unread_messages.size
    end

    retailer_users.each do |ret_u|
      redis.publish 'new_message_counter', {identifier: identifier, action: action, q: quantity, total:
        total, room: ret_u.id}.to_json
    end
  end

  def self.redis
    @redis ||= Redis.new()
  end
end
