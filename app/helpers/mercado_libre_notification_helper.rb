module MercadoLibreNotificationHelper
  def self.broadcast_data(*args)
    retailer, retailer_users, type, object = args

    sub_total_questions = retailer.unread_questions.size
    sub_total_messages = retailer.unread_messages.size
    ml_total = sub_total_questions + sub_total_messages

    if type == 'questions'
      identifier = '#item__cookie_question'
      sub_total = sub_total_questions
    elsif type == 'messages'
      identifier = '#item__cookie_message'
      sub_total = sub_total_messages
    end

    customer = object&.customer
    order = begin
              # Editar tambien en api/v1/orders
              object.order.reload.as_json(
                include: [:customer, :products],
                methods: [:unread_message, :order_img, :last_message, :unread_messages_count]
              )
            rescue
              nil
            end
    msg = object.as_json
    retailer_users.active(retailer.id).each do |ret_u|
      redis.publish 'new_message_counter', {
        identifier: identifier,
        total: sub_total,
        ml_total: ml_total,
        from: 'MercadoLibre',
        message_text: object&.question.presence || 'Archivo',
        order_id: object&.order_id,
        customer_info: customer&.full_names.presence || customer&.meli_nickname,
        execute_alert: object.present?,
        update_counter: true,
        type: type == 'messages' ? 'mercadolibre_chats' : type,
        room: ret_u.id
      }.to_json

      next unless order

      redis.publish 'ml_orders', {
        order: order,
        room: ret_u.id
      }.to_json

      redis.publish 'ml_messages', {
        message: msg,
        room: ret_u.id
      }.to_json
    end
  end

  def self.subtract_messages_counter(retailer:, order:)
    sub_total_questions = retailer.unread_questions.size
    sub_total_messages = retailer.unread_messages.size
    ml_total = sub_total_questions + sub_total_messages
    order = begin
              # Editar tambien en api/v1/orders
              order.as_json(
                include: [:customer, :products],
                methods: [:unread_message, :order_img, :last_message, :unread_messages_count]
              )
            rescue
              nil
            end

    retailer.retailer_users.active(retailer.id).each do |ret_u|
      redis.publish 'new_message_counter',
        {
          identifier: '#item__cookie_message',
          total: sub_total_messages,
          ml_total: ml_total,
          from: 'MercadoLibre',
          execute_alert: false,
          update_counter: true,
          type: 'mercadolibre_chats',
          room: ret_u.id
        }.to_json

      redis.publish 'ml_orders', {
        order: order,
        room: ret_u.id
      }.to_json
    end
  end

  def self.mark_chat_as_read(retailer:, order_web_id:)
    sub_total_questions = retailer.unread_questions.size
    sub_total_messages = retailer.unread_messages.size
    ml_total = sub_total_questions + sub_total_messages

    retailer.retailer_users.active(retailer.id).each do |ret_u|
      redis.publish 'new_message_counter',
        {
          identifier: '#item__cookie_message',
          total: sub_total_messages,
          ml_total: ml_total,
          from: 'MercadoLibre',
          execute_alert: false,
          update_counter: true,
          type: 'mercadolibre_chats',
          room: ret_u.id
        }.to_json

      redis.publish 'ml_orders',
        {
          order_web_id: order_web_id,
          room: ret_u.id
        }.to_json
    end
  end

  def self.redis
    @redis ||= Redis.new(url: ENV['REDIS_PROVIDER'] || 'redis://localhost:6379/1')
  end
end
