module MercadoLibreNotificationHelper
  def self.broadcast_data(*args)
    retailer, retailer_users, type, object = args

    identifier = if type == 'questions'
                   '#item__cookie_question'
                 elsif type == 'messages'
                   '#item__cookie_message'
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
        unread_total_messages: ret_u.ml_unread,
        unread_questions: retailer.unread_questions,
        unread_ml_messages: retailer.unread_messages,
        from: 'MercadoLibre',
        message_text: object&.question.presence || 'Archivo',
        order_id: object&.order_id,
        customer_info: customer&.full_names.presence || customer&.meli_nickname,
        execute_alert: object.present?,
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
          unread_total_messages: ret_u.ml_unread,
          unread_questions: retailer.unread_questions,
          unread_ml_messages: retailer.unread_messages,
          from: 'MercadoLibre',
          execute_alert: false,
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
    retailer.retailer_users.active(retailer.id).each do |ret_u|
      redis.publish 'new_message_counter',
        {
          identifier: '#item__cookie_message',
          unread_total_messages: ret_u.ml_unread,
          unread_questions: retailer.unread_questions,
          unread_ml_messages: retailer.unread_messages,
          from: 'MercadoLibre',
          execute_alert: false,
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
