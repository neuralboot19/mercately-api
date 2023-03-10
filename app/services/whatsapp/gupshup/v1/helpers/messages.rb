module Whatsapp::Gupshup::V1::Helpers
  class Messages
    def initialize(msg=nil)
      @msg = msg
    end

    def broadcast!
      raise StandardError.new('Mensaje no especificado') unless @msg.present?

      serialized_message = JSON.parse(serialize_message)

      retailer = @msg.retailer
      agents = @msg.customer.agent.present? ? [@msg.customer.agent] : retailer.retailer_users.all_customers.to_a
      retailer_users = agents | retailer.admins | retailer.supervisors

      retailer_users.each do |ret_u|
        notify_update!(ret_u, serialized_message)
      end
    rescue StandardError => e
      Rails.logger.error(e)
      SlackError.send_error(e)
    end

    def notify_agent!(*args)
      retailer, retailer_users, assigned_agent, customer = args

      retailer_users = retailer_users | retailer.admins | retailer.supervisors

      retailer_users.each do |ret_u|
        remove = ret_u.remove_agent?(assigned_agent)

        redis.publish 'customer_chat',
                      {
                        customer: serialize_customer(customer),
                        remove_only: remove,
                        room: ret_u.id
                      }.to_json

        notify_new_counter(ret_u, customer, remove)
      end
    rescue StandardError => e
      Rails.logger.error(e)
      SlackError.send_error(e)
    end

    def notify_messages!(retailer, retailer_users)
      serialized_message = JSON.parse(serialize_message)
      retailer_users = retailer_users | retailer.admins | retailer.supervisors

      retailer_users.each do |ret_u|
        notify_update!(ret_u, serialized_message)
      end

      serialized_message['data'].pluck('attributes')
    rescue StandardError => e
      Rails.logger.error(e)
      SlackError.send_error(e)
    end

    def notify_read!(retailer, retailer_users)
      serialized_message = JSON.parse(serialize_message)
      retailer_users = retailer_users | retailer.admins | retailer.supervisors

      retailer_users.each do |ret_u|
        notify_new_counter(ret_u)
      end

      serialized_message['data']['attributes']
    rescue StandardError => e
      Rails.logger.error(e)
      SlackError.send_error(e)
    end

    def notify_new_counter(*args)
      # Set all local vars
      retailer_user,
      customer,
      removed_agent = args

      customer&.reload

      if @msg.is_a?(ActiveRecord::AssociationRelation)
        customer ||= @msg.first.customer
        message = @msg.first
        execute = false
      else
        customer ||= @msg&.customer
        message = @msg
        execute = true
      end

      redis.publish 'new_message_counter',
                    {
                      identifier: '.item__cookie_whatsapp_messages',
                      unread_messages: retailer_user.whatsapp_unread,
                      unread_chats_count: retailer_user.unread_whatsapp_chats_count,
                      from: 'WhatsApp',
                      message_text: message_info(message),
                      customer_info: customer&.notification_info,
                      execute_alert: execute && message&.direction == 'inbound',
                      room: retailer_user.id
                    }.to_json

      serialized_customer = serialize_customer(customer)
      remove = customer.agent.present? ? (
        customer.persisted? &&
        customer&.agent&.id != retailer_user.id &&
        retailer_user.admin? == false &&
        retailer_user.supervisor? == false
      ) : false
      customer_chat_args = {
        customer: serialized_customer,
        remove_only: remove || removed_agent,
        room: retailer_user.id
      }

      redis.publish 'customer_chat', customer_chat_args.to_json
    end

    def notify_customer_update!(*args)
      retailer,
      retailer_users,
      customer = args

      retailer_users = retailer_users | retailer.admins | retailer.supervisors

      retailer_users.each do |ru|
        notify_new_counter(ru, customer)
      end
    end

    def serialize_gupshup_messages
      JSON.parse(serialize_message)['data'].pluck('attributes')
    end

    private

      def redis
        @redis ||= Redis.new(url: ENV['REDIS_PROVIDER'] || 'redis://localhost:6379/1')
      end

      def serialize_customer(customer)
        ActiveModelSerializers::Adapter::Json.new(
          GupshupCustomerSerializer.new(customer)
        ).serializable_hash
      end

      def serialize_message
        GupshupWhatsappMessageSerializer.new(
          @msg
        ).serialized_json
      end

      def notify_update!(retailer_user, serialized_message)
        # TODO: Change the element name karix_whatsapp_message to something more
        # standard like whatsapp_message, I decided to keep this name to not
        # touch front-end at all
        all_messages = if serialized_message['data'].is_a?(Array)
                         serialized_message['data'].pluck('attributes')
                       else
                         serialized_message['data']['attributes']
                       end
        redis.publish 'message_chat',
                      {
                        karix_whatsapp_message: {
                          karix_whatsapp_message: all_messages
                        },
                        room: retailer_user.id
                      }.to_json

        notify_new_counter(retailer_user)
      end

      def message_info(message)
        return '' unless message.present?

        return 'Archivo' if message.type == 'file'
        return 'Imagen' if message.type == 'image'
        return 'Video' if message.type == 'video'
        return 'Audio' if ['audio', 'voice'].include?(message.type)
        return 'Ubicaci??n' if message.type == 'location'
        return 'Contacto' if message.type == 'contact'
        return 'Sticker' if message.type == 'sticker'
        message.message_payload['payload'].try(:[], 'payload').try(:[], 'text') || message.message_payload['text']
      end
  end
end
