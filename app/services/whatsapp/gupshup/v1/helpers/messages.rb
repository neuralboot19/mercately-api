module Whatsapp::Gupshup::V1::Helpers
  class Messages
    def initialize(msg=nil)
      @msg = msg
    end

    def broadcast!
      raise StandardError.new('Mensaje no especificado') unless @msg.present?

      serialized_message = JSON.parse(serialize_message)

      retailer = @msg.retailer
      agents = @msg.customer.agent.present? ? [@msg.customer.agent] : retailer.retailer_users.to_a
      retailer_users = agents | retailer.admins

      retailer_users.each do |ret_u|
        notify_update!(ret_u, serialized_message)
      end
    rescue StandardError => e
      Rails.logger.error(e)
    end

    def notify_agent!(retailer, retailer_users, assigned_agent)
      retailer_users = retailer_users | retailer.admins

      retailer_users.each do |ret_u|
        remove = assigned_agent.persisted? &&
          assigned_agent.retailer_user_id != ret_u.id &&
          ret_u.retailer_admin == false

        redis.publish 'customer_chat',
                      {
                        customer: serialize_customer(assigned_agent.customer),
                        remove_only: remove,
                        room: ret_u.id
                      }.to_json

        notify_new_counter(ret_u, assigned_agent.customer)
      end
    rescue StandardError => e
      Rails.logger.error(e)
    end

    def notify_messages!(retailer, retailer_users)
      serialized_message = JSON.parse(serialize_message)
      retailer_users = retailer_users | retailer.admins

      retailer_users.each do |ret_u|
        notify_update!(ret_u, serialized_message)
      end

      serialized_message['data'].pluck('attributes')
    rescue StandardError => e
      Rails.logger.error(e)
    end

    def notify_read!(retailer, retailer_users)
      serialized_message = JSON.parse(serialize_message)
      retailer_users = retailer_users | retailer.admins

      retailer_users.each do |ret_u|
        notify_new_counter(ret_u)
      end

      serialized_message['data']['attributes']
    rescue StandardError => e
      Rails.logger.error(e)
    end

    def notify_new_counter(*args)
      # Set all local vars
      retailer_user,
      customer= args

      total = retailer_user.retailer.gupshup_unread_whatsapp_messages(retailer_user).size

      redis.publish 'new_message_counter',
                    {
                      identifier: '.item__cookie_whatsapp_messages',
                      total: total,
                      room: retailer_user.id
                    }.to_json

      customer ||= if @msg.is_a?(ActiveRecord::AssociationRelation)
                     @msg.first.customer
                   else
                     @msg.customer
                   end
      serialized_customer = serialize_customer(customer)
      remove = customer.agent.present? ? (
        customer.persisted? &&
        customer&.agent&.id != retailer_user.id &&
        retailer_user.retailer_admin == false
      ) : false
      customer_chat_args = {
        customer: serialized_customer,
        remove_only: remove,
        room: retailer_user.id
      }

      redis.publish 'customer_chat', customer_chat_args.to_json
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
  end
end
