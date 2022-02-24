module ProcessMessageQueueConcern
  extend ActiveSupport::Concern

  included do
    after_commit :create_messages, on: :create, if: :process_queue
  end

  private

    def create_messages
      customer_queue = if number_to_use.present?
                         CustomerQueue.where(retailer_id: retailer.id).in(source: [phone, number_to_use]).first
                       else
                         CustomerQueue.find_by(retailer_id: retailer.id, source: phone)
                       end

      return unless customer_queue.present?

      messages = customer_queue.message_queues.order(created_at: :asc)
      messages.each_with_index do |msg, index|
        if customer_queue.retry_customer_count > 0 &&
          gupshup_whatsapp_messages.where(whatsapp_message_id: msg.payload['payload']['id']).exists?

          msg.update(processed: true)
          next
        end

        # Store in our database the incoming text message
        gwm = GupshupWhatsappMessage.create!(
          retailer: retailer,
          customer: self,
          whatsapp_message_id: msg.payload['payload']['id'],
          gupshup_message_id: msg.payload['payload']['id'],
          status: :delivered,
          direction: 'inbound',
          message_payload: msg.payload,
          source: msg.payload['payload']['source'],
          destination: retailer.whatsapp_phone_number(false),
          channel: 'whatsapp',
          delivered_at: msg.created_at,
          sent_at: msg.payload['timestamp'],
          skip_automatic: index > 0,
          created_at: msg.created_at
        )

        # Marcamos el mensaje en la cola como procesado
        msg.update(processed: true)

        # Broadcast to the proper chat
        broadcast(gwm)
      end

      # Destruimos la cola luego de procesada
      customer_queue.destroy
    rescue StandardError => e
      customer_queue.retry_customer_process(self) if customer_queue.present?
      Rails.logger.error(e)
      SlackError.send_error(e)
    end

    def broadcast(msg)
      Whatsapp::Gupshup::V1::Helpers::Messages.new(msg).broadcast!
    end
end
