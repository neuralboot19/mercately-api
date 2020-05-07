module Whatsapp
  module Karix
    class Messages
      def assign_message(message, retailer, ws_data)
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
          ws_data['updated_time'], status: ws_data['status'], direction: ws_data['direction'], channel:
          ws_data['channel'], error_code: ws_data['error']&.[]('code'), error_message:
          ws_data['error']&.[]('message'), message_type: ws_data['channel_details']&.[]('whatsapp')&.[]('type'),
          customer_id: customer&.id }

        message
      end

      def send_message(retailer, customer, params, type)
        url = ws_api.prepare_send_whatsapp_message_url
        conn = prepare_connection(retailer, url)
        response = Connection.post_request(conn, prepare_message_body(retailer, customer, params, type))
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
        conn.basic_auth(ENV['KARIX_ACCOUNT_UID'], ENV['KARIX_ACCOUNT_TOKEN'])
        conn.headers['Authorization']

        conn
      end

      def prepare_message_body(retailer, customer, params, type)
        case type
          when 'text'
            ws_api.prepare_whatsapp_message_text(retailer, customer, params)
          when 'file'
            ws_api.prepare_whatsapp_message_file(retailer, customer, params)
        end
      end

      def send_welcome_message(retailer)
        url = ws_api.prepare_send_whatsapp_message_url
        conn = prepare_connection(retailer, url)
        response = Connection.post_request(conn, ws_api.prepare_welcome_message_body(retailer))
        JSON.parse(response.body)
      end
    end
  end
end
