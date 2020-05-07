module Whatsapp::Gupshup::V1::Helpers
  class Messages
    def initialize(msg=nil)
      @msg = msg
    end

    def broadcast!
      raise StandardError.new('Mensaje no especificado') unless @msg.present?

      serialized_message = JSON.parse(serialize_message)
      serialized_customer = serialize_customer(@msg.customer)

      retailer = @msg.retailer
      agents = @msg.customer.agent.present? ? [@msg.customer.agent] : retailer.retailer_users.to_a
      retailer_users = agents | retailer.admins

      retailer_users.each do |ret_u|
        notify_update!(ret_u, serialized_message, serialized_customer)
      end
    rescue StandardError => e
      Rails.logger.error(e)
    end

    def self.notify_agent!(retailer, retailer_users, assigned_agent)
      unless assigned_agent.present? &&
             retailer_users.present? &&
             retailer.present?
        raise StandardError.new('Faltan datos')
      end

      retailer_users = retailer_users | retailer.admins

      retailer_users.each do |ret_u|
        remove_only = assigned_agent.persisted? &&
                      assigned_agent.retailer_user_id != ret_u.id &&
                      ret_u.retailer_admin == false

        redis.publish 'customer_chat',
                      {
                        customer: serialize_customer(assigned_agent.customer),
                        remove_only: remove_only,
                        room: ret_u.id
                      }.to_json
      end
    rescue StandardError => e
      Rails.logger.error(e)
    end

    def notify_messages!(retailer, retailer_users, customer, nomore=false)
      unless retailer_users.present? &&
             retailer.present?
        raise StandardError.new('Faltan datos')
      end
      serialized_message = JSON.parse(serialize_message)
      serialized_customer = serialize_customer(customer)

      retailer_users = retailer_users | retailer.admins

      retailer_users.each do |ret_u|
        notify_update!(ret_u, serialized_message, serialized_customer) unless nomore
      end
      serialized_message['data'].pluck('attributes')
    rescue StandardError => e
      Rails.logger.error(e)
    end

    private

      def redis
        @redis ||= Redis.new()
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

      def notify_update!(retailer_user, serialized_message, serialized_customer)
        total = retailer_user.retailer.gupshup_unread_whatsapp_messages(retailer_user).size

        redis.publish 'new_message_counter',
                      {
                        identifier: '.item__cookie_whatsapp_messages',
                        total: total,
                        room: retailer_user.id
                      }.to_json

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

        redis.publish 'customer_chat',
                      {
                        customer: serialized_customer,
                        room: retailer_user.id
                      }.to_json
      end
  end
end
