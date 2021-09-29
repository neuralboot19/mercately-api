module Whatsapp::Gupshup::V1
  class EventHandler < Base

    def process_event!(params)
      # Check direction
      @params = params
      gsw_type = @params['type']
      direction = ['message', 'quick_reply'].include?(gsw_type) ? 'inbound' : 'message_event'
      Rails.logger.debug '*'.*100
      Rails.logger.debug "PARAMS: #{params}"
      Rails.logger.debug "DIRECTION: #{direction}"
      Rails.logger.debug '*'.*100
      # Call direction method
      self.send(direction)
    end

    def process_error!(params)
      # Gupshup Message Id
      event_id = params['payload']['id']

      # Find the message by its GupShup Message Id
      gwm = GupshupWhatsappMessage.find_by_gupshup_message_id(event_id)
      raise StandardError.new("El mensaje ID #{event_id} no fue encontrado") unless gwm.present?

      # Store the message as :failed
      gwm.status = :error
      gwm.error_payload = params

      gwm.with_advisory_lock(gwm.to_global_id.to_s) do
        gwm.save!

        # Broadcast to the proper chat
        broadcast(gwm)
      end
    end

    private

      def inbound
        # Find or Store the client
        customer = save_customer

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

        if new_event == 'enqueued'
          # Get Whatsapp Message Id and Gupshup Message Id
          wm_id = @params['payload']['payload']['whatsappMessageId']
          event_id = @params['payload']['id']

          # Find the stored message by Gupshup Message Id
          gwm = GupshupWhatsappMessage.find_by_gupshup_message_id(event_id)
          raise StandardError.new("El mensaje ID #{event_id} no fue encontrado") unless gwm.present?

          # Update the Whatsapp Message Id with the incoming one
          gwm.whatsapp_message_id = wm_id

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

          gwm.with_advisory_lock(gwm.to_global_id.to_s) do
            gwm.save!
            broadcast(gwm.reload)
          end
        else
          gs_id = @params['payload']['gsId']
          gwm = GupshupWhatsappMessage.find_by_gupshup_message_id(gs_id)

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

              gwm.with_advisory_lock(gwm.to_global_id.to_s) do
                gwm.save!
                broadcast(gwm.reload)
              end
            end
          else
            wm_id = @params['payload']['id']
            GupshupWhatsappMessage.with_advisory_lock(
              "#{@retailer.to_global_id}_#{wm_id}"
            ) do
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
        end
        true
      rescue StandardError => e
        Rails.logger.error(e)
        # SlackError.send_error(e)
        false
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

      def broadcast(msg)
        Whatsapp::Gupshup::V1::Helpers::Messages.new(msg).broadcast!
      end
  end
end
