module Whatsapp
  module Karix
    class Messages
      def assign_message(message, retailer, ws_data, retailer_user = nil)
        customer = ws_customer_service.save_customer(retailer, ws_data)

        message.attributes = { account_uid: ws_data['account_uid'], source: ws_data['source'], destination:
          ws_data['destination'], country: ws_data['country'], content_type: ws_data['content_type'], content_text:
          ws_data['content']&.[]('text'), content_location_longitude:
          ws_data['content']&.[]('location')&.[]('longitude'), content_location_latitude:
          ws_data['content']&.[]('location')&.[]('latitude'), content_location_label:
          ws_data['content']&.[]('location')&.[]('label'), content_location_address:
          ws_data['content']&.[]('location')&.[]('address'), content_media_url:
          ws_data['content']&.[]('media')&.[]('url'), content_media_caption:
          ws_data['content']&.[]('media')&.[]('caption'), content_media_type:
          ws_data['content']&.[]('media')&.[]('type'), created_time: ws_data['created_time'], sent_time:
          ws_data['sent_time'], delivered_time: ws_data['delivered_time'], updated_time:
          ws_data['updated_time'], status: catch_status(message, ws_data['status']), direction:
          ws_data['direction'], channel: ws_data['channel'], error_code: ws_data['error']&.[]('code'), error_message:
          ws_data['error']&.[]('message'), message_type:
          ws_data['channel_details']&.[]('whatsapp')&.[]('type'), customer_id: customer&.id, retailer_user_id:
          message.retailer_user&.id || retailer_user&.id }

        message
      end

      def send_message(retailer, customer, params, type)
        url = ws_api.prepare_send_whatsapp_message_url
        conn = prepare_connection(retailer, url)
        response = Connection.post_request(conn, prepare_message_body(retailer: retailer, customer: customer,
          params: params, type: type))
        JSON.parse(response.body)
      end

      def ws_customer_service
        @ws_customer_service = Whatsapp::Karix::Customers.new
      end

      def ws_api
        @ws_api = Whatsapp::Karix::Api.new
      end

      def prepare_connection(retailer, url)
        conn = Connection.prepare_connection(url)
        conn.basic_auth(retailer.karix_account_uid, retailer.karix_account_token)
        conn.headers['Authorization']

        conn
      end

      def prepare_message_body(args)
        case args[:type]
        when 'text'
          ws_api.prepare_whatsapp_message_text(args[:retailer], args[:customer], args[:params])
        when 'file'
          ws_api.prepare_whatsapp_message_file(args[:retailer], args[:customer], args[:params], args[:index])
        when 'location'
          ws_api.prepare_whatsapp_message_location(args[:retailer], args[:customer], args[:params])
        end
      end

      def send_welcome_message(retailer)
        url = ws_api.prepare_send_whatsapp_message_url
        conn = prepare_connection(retailer, url)
        response = Connection.post_request(conn, ws_api.prepare_welcome_message_body(retailer))
        JSON.parse(response.body)
      end

      def send_bulk_files(args)
        return unless prepare_send_files(args)

        has_agent = args[:customer].agent_customer.present?
        return if has_agent

        # Si el customer no tiene un agente asignado aun, se le asigna
        # al que envia el primer mensaje
        AgentCustomer.create_with(retailer_user: args[:retailer_user])
                    .find_or_create_by(customer: args[:customer])

        karix_helper = KarixNotificationHelper
        karix_helper.broadcast_data(args[:retailer], args[:retailer].retailer_users.all_customers.to_a, nil,
                                    args[:customer].agent_customer)
      end

      private

        def catch_status(message, status)
          return status if message.status.blank?

          statuses = %w[queued failed received sent rejected undelivered delivered read]
          return status if statuses.index(status).blank?

          statuses.index(status) > statuses.index(message.status) ? status : message.status
        end

        def prepare_send_files(args)
          url = ws_api.prepare_send_whatsapp_message_url
          conn = prepare_connection(args[:retailer], url)
          karix_helper = KarixNotificationHelper
          sent = false

          args[:params][:file_data]&.each_with_index do |file, index|
            response = Connection.post_request(conn, prepare_message_body(retailer: args[:retailer], customer:
              args[:customer], params: args[:params], type: args[:type], index: index))
            response = JSON.parse(response.body)
            next if response['error'].present?

            message = args[:retailer].karix_whatsapp_messages.find_or_initialize_by(uid: response['objects'][0]['uid'])
            message = karix_helper.ws_message_service.assign_message(message, args[:retailer], response['objects'][0],
                                                                    args[:retailer_user])
            message.save
            sent = true
          end

          sent
        end
    end
  end
end
