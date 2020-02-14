require 'mime/types'

module Facebook
  class Messages
    def initialize(facebook_retailer)
      @facebook_retailer = facebook_retailer
    end

    def save(message_data)
      customer = Facebook::Customers.new(@facebook_retailer).import(message_data['sender']['id'])
      FacebookMessage.create_with(
        customer: customer,
        facebook_retailer: @facebook_retailer,
        sender_uid: message_data['sender']['id'],
        id_client: message_data['sender']['id'],
        text: message_data['message']&.[]('text'),
        file_type: message_data['message']&.[]('attachments')&.[](0)&.[]('type'),
        url: message_data['message']&.[]('attachments')&.[](0)&.[]('payload')&.[]('url'),
        reply_to: message_data['message']&.[]('reply_to')&.[]('mid')
      ).find_or_create_by(mid: message_data['message']['mid'])
    end

    def import_delivered(message_id, psid)
      url = message_url(message_id)
      conn = Connection.prepare_connection(url)
      response = Connection.get_request(conn)
      save_delivered(response, psid) if response
    end

    def save_delivered(response, psid)
      customer = Customer.find_by(psid: psid)
      attachment_url = response['attachments']&.[]('data')&.[](0)&.[]('image_data')&.[]('url')
      file_type = response['attachments']&.[]('data')&.[](0)&.[]('mime_type')
      message = FacebookMessage.create_with(
        customer: customer,
        facebook_retailer: @facebook_retailer,
        sender_uid: @facebook_retailer.uid,
        id_client: psid,
        file_type: file_type,
        url: attachment_url,
        text: response['message']
      ).find_or_create_by(mid: response['id'])
      if attachment_url && message.url.nil?
        message.update(
          url: attachment_url,
          file_type: file_type
        )
      end
    end

    def send_message(to, message)
      url = send_message_url
      conn = Connection.prepare_connection(url)
      response = Connection.post_request(conn, prepare_message(to, message))
      JSON.parse(response.body)
    end

    def send_attachment(to, file_data)
      conn = Faraday.new(send_message_url) do |f|
        f.request :multipart
        f.request :url_encoded
        f.adapter :net_http
        f.response :logger, Logger.new(STDOUT), bodies: true
      end
      response = Connection.post_form_request(conn, prepare_attachment(to, file_data))
      JSON.parse(response.body)
    end

    private

      def prepare_message(to, message)
        {
          "recipient": {
            "id": to
          },
          "message": {
            "text": message
          }
        }.to_json
      end

      def prepare_attachment(to, file_path)
        content_type = MIME::Types.type_for(file_path).first.content_type
        {
          "recipient": JSON.dump(id: to),
          "message": JSON.dump(attachment: {
            "type": 'image',
            "payload": {}
          }),
          "filedata": Faraday::UploadIO.new(file_path, content_type)
        }
      end

      def send_message_url
        params = {
          access_token: @facebook_retailer.access_token
        }
        "https://graph.facebook.com/v5.0/me/messages?#{params.to_query}"
      end

      def message_url(message_id)
        params = {
          fields: 'message,attachments,created_time,to,from',
          access_token: @facebook_retailer.access_token
        }
        "https://graph.facebook.com/#{message_id}?#{params.to_query}"
      end
  end
end
