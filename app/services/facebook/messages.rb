require 'mime/types'

module Facebook
  class Messages
    def initialize(facebook_retailer)
      @facebook_retailer = facebook_retailer
    end

    def save(message_data)
      customer = Facebook::Customers.new(@facebook_retailer).import(message_data['sender']['id'])
      url = message_data['message']&.[]('attachments')&.[](0)&.[]('payload')&.[]('url')
      file_name = File.basename(URI.parse(url)&.path) if url.present?
      message = FacebookMessage.create_with(
        customer: customer,
        facebook_retailer: @facebook_retailer,
        sender_uid: message_data['sender']['id'],
        id_client: message_data['sender']['id'],
        text: message_data['message']&.[]('text'),
        file_type: message_data['message']&.[]('attachments')&.[](0)&.[]('type'),
        url: url,
        reply_to: message_data['message']&.[]('reply_to')&.[]('mid'),
        filename: file_name
      ).find_or_create_by(mid: message_data['message']['mid'])
      if message.persisted?
        serialized_data = ActiveModelSerializers::Adapter::Json.new(
          FacebookMessageSerializer.new(message)
        ).serializable_hash
        redis.publish 'message_facebook_chat', {facebook_message: serialized_data, room:
          @facebook_retailer.retailer.id}.to_json

        serialized_data = ActiveModelSerializers::Adapter::Json.new(
          CustomerSerializer.new(customer)
        ).serializable_hash
        redis.publish 'customer_facebook_chat', {customer: serialized_data, room:
          @facebook_retailer.retailer.id}.to_json
      end
    end

    def import_delivered(message_id, psid)
      url = message_url(message_id)
      conn = Connection.prepare_connection(url)
      response = Connection.get_request(conn)
      save_delivered(response, psid) if response
    end

    def save_delivered(response, psid)
      customer = Customer.find_by(psid: psid)
      attachment = response['attachments']&.[]('data')&.[](0)
      file_type = attachment&.[]('mime_type')
      file_name = attachment&.[]('name')
      attachment_url = grab_url(response, file_type)
      message = FacebookMessage.create_with(
        customer: customer,
        facebook_retailer: @facebook_retailer,
        sender_uid: @facebook_retailer.uid,
        id_client: psid,
        file_type: file_type,
        url: attachment_url,
        text: response['message'],
        filename: file_name
      ).find_or_create_by(mid: response['id'])
      if attachment_url && message.url.nil?
        message.update(
          url: attachment_url,
          file_type: file_type,
          filename: message.filename.presence || file_name
        )
        serialized_data = ActiveModelSerializers::Adapter::Json.new(
          FacebookMessageSerializer.new(message)
        ).serializable_hash
        redis.publish 'message_facebook_chat', {facebook_message: serialized_data, room:
          @facebook_retailer.retailer.id}.to_json

        serialized_data = ActiveModelSerializers::Adapter::Json.new(
          CustomerSerializer.new(customer)
        ).serializable_hash
        redis.publish 'customer_facebook_chat', {customer: serialized_data, room:
          @facebook_retailer.retailer.id}.to_json
      end
    end

    def send_message(to, message)
      url = send_message_url
      conn = Connection.prepare_connection(url)
      response = Connection.post_request(conn, prepare_message(to, message))
      JSON.parse(response.body)
    end

    def send_attachment(to, file_data, filename)
      conn = Faraday.new(send_message_url) do |f|
        f.request :multipart
        f.request :url_encoded
        f.adapter :net_http
        f.response :logger, Logger.new(STDOUT), bodies: true
      end
      response = Connection.post_form_request(conn, prepare_attachment(to, file_data, filename))
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

      def prepare_attachment(to, file_path, filename)
        content_type = MIME::Types.type_for(file_path).first.content_type
        type = check_content_type(content_type)

        {
          "recipient": JSON.dump(id: to),
          "message": JSON.dump(attachment: {
            "type": type,
            "payload": {}
          }),
          "filedata": Faraday::UploadIO.new(file_path, content_type, filename)
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

      def redis
        @redis ||= Redis.new()
      end

      def check_content_type(content_type)
        return unless content_type.present?
        return 'image' if content_type.include?('image/')
        return 'file' if ['application/pdf', 'application/msword',
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document'].include?(content_type)
      end

      def grab_url(response, content_type)
        type = check_content_type(content_type)
        return unless type.present?

        attachment = response['attachments']&.[]('data')&.[](0)
        return attachment&.[]('image_data')&.[]('url') if type == 'image'

        attachment&.[]('file_url')
      end
  end
end
