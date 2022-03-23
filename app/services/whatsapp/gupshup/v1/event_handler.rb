module Whatsapp::Gupshup::V1
  class EventHandler < Base

    def process_event!(params)
      # Check direction
      @params = params
      gsw_type = @params['type']
      direction = case gsw_type
                  when 'message', 'quick_reply'
                    'inbound'
                  when 'message-event'
                    'message_event'
                  when 'billing-event'
                    'billing_event'
                  end

      Rails.logger.debug '*'.*100
      Rails.logger.debug "PARAMS: #{params}"
      Rails.logger.debug "DIRECTION: #{direction}"
      Rails.logger.debug '*'.*100
      return unless direction.present?

      # Call direction method
      self.send(direction)
    end

    def process_error!(params)
      app_name = params['app']
      phone_to_find = params['payload']['source'] || params['payload']['destination'] ||
        params['gupshup_whatsapp']['payload']['source'] || params['gupshup_whatsapp']['payload']['destination']
      phone_to_find = "+#{phone_to_find}"
      # Gupshup Message Id
      event_id = params['payload']['gsId'] || params['payload']['id']

      # Find the message by its GupShup Message Id
      gwm = find_gupshup_message(app_name, phone_to_find, event_id)
      if gwm.blank?
        error_msg = "El mensaje ID #{event_id} no fue encontrado"
        WhatsappLog.create(error_message: error_msg, response: params, retailer: @retailer, gupshup_message_id: event_id)
        SlackError.send_error(error_msg)
        raise StandardError, error_msg
      end

      # Store the message as :failed
      gwm.status = :error
      gwm.error_payload = params
      WhatsappLog.create(
        response: params,
        gupshup_whatsapp_message: gwm,
        retailer: @retailer,
        gupshup_message_id: event_id
      )

      gwm.with_advisory_lock(gwm.to_global_id.to_s) do
        gwm.save!

        # Broadcast to the proper chat
        broadcast(gwm)
      end
    rescue StandardError => e
      Rails.logger.error(e)
      SlackError.send_error(e)
      Raven.capture_exception(e)
    end

    def process_queue_message!(message_queue)
      return if @retailer.blank? || @customer.blank?

      gwm = GupshupWhatsappMessage.create!(
        retailer: @retailer,
        customer: @customer,
        whatsapp_message_id: message_queue.payload[:payload][:id],
        gupshup_message_id: message_queue.payload[:payload][:id],
        status: :delivered,
        direction: 'inbound',
        message_payload: message_queue.payload,
        source: message_queue.payload[:payload][:source],
        destination: @retailer.whatsapp_phone_number(false),
        channel: 'whatsapp',
        delivered_at: message_queue.created_at,
        sent_at: message_queue.payload[:timestamp],
        skip_automatic: true,
        created_at: message_queue.created_at
      )

      # Broadcast to the proper chat
      broadcast(gwm)
    rescue StandardError => e
      Rails.logger.error(e)
      SlackError.send_error(e)
      false
    end

    private

      def inbound
        # Find or Store the client
        customer = save_customer
        return unless customer.present?

        # Store in our database the incoming text message
        GupshupWhatsappMessage.with_advisory_lock(
          "#{@retailer.to_global_id}_#{customer.to_global_id}"
        ) do
          gwm = GupshupWhatsappMessage.create!(
            retailer: @retailer,
            customer: customer,
            whatsapp_message_id: @params[:payload][:id],
            gupshup_message_id: @params[:payload][:id],
            status: :delivered,
            direction: 'inbound',
            message_payload: @params,
            source: @params[:payload][:source],
            destination: @retailer.whatsapp_phone_number(false),
            channel: 'whatsapp',
            delivered_at: Time.zone.now.to_i,
            sent_at: @params[:timestamp]
          )

          # Broadcast to the proper chat
          broadcast(gwm)
        end
      rescue StandardError => e
        Rails.logger.error(e)
        SlackError.send_error(e)
        false
      end

      def message_event
        # Get incoming new event
        new_event = @params['payload']['type']
        app_name = @params['app']

        phone_to_find = @params['payload']['source'] || @params['payload']['destination'] ||
          @params['gupshup_whatsapp']['payload']['source'] || @params['gupshup_whatsapp']['payload']['destination']
        phone_to_find = "+#{phone_to_find}"

        case new_event
        when 'enqueued'
          # Get Whatsapp Message Id and Gupshup Message Id
          wm_id = @params['payload']['payload']['whatsappMessageId']
          event_id = @params['payload']['id']
          type = @params['payload']['payload']['type']
          message_type = if type == 'session'
                           'conversation'
                         elsif type == 'template'
                           'notification'
                         end

          # Find the stored message by Gupshup Message Id
          gwm = find_gupshup_message(app_name, phone_to_find, event_id)
          raise StandardError.new("El mensaje ID #{event_id} no fue encontrado") unless gwm.present?

          # Update the Whatsapp Message Id with the incoming one
          gwm.whatsapp_message_id = wm_id
          # Update message type with result from GS
          gwm.message_type = message_type

          # Find for all temporal events stored
          temp_events = GupshupTemporalMessageState.where(whatsapp_message_id: wm_id)
                                                   .order(event: :desc)

          if temp_events.any?
            # Get the last last event from whatsapp
            top_temp_event = temp_events.first

            # If the stored message event < last whatsapp event
            if number_status_by_sym(gwm.status.to_sym) < top_temp_event.event
              # Updates the
              gwm.status = top_temp_event.status.to_s
              gwm["#{gwm.status.to_s}_at"] = top_temp_event.event_timestamp unless top_temp_event.status == :enqueued
            else
              gwm.status = 'sent'
            end

            temp_events.destroy_all if top_temp_event.event == 5
          end

          # gwm.with_advisory_lock(gwm.to_global_id.to_s) do
          # end
          gwm.save!
          broadcast(gwm.reload)
        when 'mismatch'
          find_customer(@retailer, phone_to_find, 'mismatch')
        when 'sent'
          event_id = @params['payload']['gsId']
          gwm = find_gupshup_message(app_name, phone_to_find, event_id)
          raise StandardError.new("El mensaje ID #{event_id} no fue encontrado") unless gwm.present?

          Whatsapp::Gupshup::V1::ConversationDebit.new(@retailer, gwm.customer).track_conversation(gwm, @params)
        else
          gs_id = @params['payload']['gsId']
          gwm = find_gupshup_message(app_name, phone_to_find, gs_id)

          if gwm
            if number_status_by_sym(gwm.status.to_sym) < number_status_by_sym(new_event.to_sym)
              gwm.status = new_event
              gwm["#{gwm.status.to_s}_at"] = @params['timestamp'].to_i unless new_event == 'submitted'

              temp_events = GupshupTemporalMessageState.where(gupshup_message_id: gs_id)
                                                       .order(event: :desc)
              if new_event == 'read'
                # Destroy all temporal events stored  if event is read
                temp_events.destroy_all
              end

              # gwm.with_advisory_lock(gwm.to_global_id.to_s) do
              # end
              gwm.save!
              broadcast(gwm.reload)
            end
          else
            wm_id = @params['payload']['id']
            # GupshupWhatsappMessage.with_advisory_lock(
            #   "#{@retailer.to_global_id}_#{wm_id}"
            # ) do
            # end
            GupshupTemporalMessageState.create(
              gupshup_message_id: gs_id,
              whatsapp_message_id: wm_id,
              event: number_status_by_sym(new_event.to_sym),
              retailer_id: @retailer.id,
              destination: @params['payload']['destination'],
              event_timestamp: @params['timestamp'].to_i
            )
          end
        end
        true
      rescue StandardError => e
        Rails.logger.error(e)
        # SlackError.send_error(e)
        false
      end

      def billing_event
        phone_to_find = @params['payload']['references']['destination']
        phone_to_find = "+#{phone_to_find}"
        gs_id = @params['payload']['references']['gsId']
        app_name = @params['app']

        gwm = find_gupshup_message(app_name, phone_to_find, gs_id)
        customer = gwm&.customer || find_customer(@retailer, phone_to_find)

        Whatsapp::Gupshup::V1::ConversationDebit.new(@retailer, customer).process_debit(gwm, @params)
      end

      def number_status_by_sym(event)
        {enqueued: 2, sent: 3, delivered: 4, read: 5}[event]
      end

      def save_customer
        Helpers::Customers.save_customer(
          @retailer,
          @params.merge(direction: 'inbound')
        )
      end

      def find_gupshup_message(app_name, phone, id)
        retailer = Retailer.find_by(gupshup_src_name: app_name)
        customer = find_customer(retailer, phone)
        return if customer.blank?

        customer.gupshup_whatsapp_messages.find_by_gupshup_message_id(id)
      end

      def find_customer(retailer, phone, from = nil)
        customer = retailer.customers.find_by(phone: phone)
        return customer if customer.present?

        parse_phone = Phonelib.parse(phone)
        country = parse_phone&.country
        original_phone = phone.dup

        if country == 'MX' && phone[3] != '1'
          phone = phone.insert(3, '1')
          add_number = original_phone != phone
          customer = retailer.customers.find_by(phone: phone)
        end

        return unless customer.present?

        if add_number && from == 'mismatch'
          customer.update_columns(number_to_use: original_phone, number_to_use_opt_in: true)
        end

        customer
      end

      def broadcast(msg)
        Whatsapp::Gupshup::V1::Helpers::Messages.new(msg).broadcast!
      end
  end
end
