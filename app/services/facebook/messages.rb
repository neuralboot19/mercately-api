require 'mime/types'
require 'open-uri'

module Facebook
  class Messages
    def initialize(facebook_retailer, type = 'messenger')
      @type = type
      @facebook_retailer = facebook_retailer
      @klass = @type == 'instagram' ? InstagramMessage : FacebookMessage
    end

    def save(message_data)
      customer = Facebook::Customers.new(@facebook_retailer, @type).import(message_data['sender']['id'])
      file_type = message_data['message']&.[]('attachments')&.[](0)&.[]('type')
      url = file_type_url(message_data, file_type)
      url, file_type = get_fallback_media_url(url) if file_type == 'fallback'
      file_name = File.basename(URI.parse(url)&.path) if url.present?
      file_type = sniff_mime_type(url) if @type == 'instagram' && file_type.in?(['story_mention', 'share'])
      @klass.create_with(
        customer: customer,
        facebook_retailer: @facebook_retailer,
        sender_uid: message_data['sender']['id'],
        id_client: message_data['sender']['id'],
        text: message_data['message']&.[]('text'),
        file_type: file_type,
        url: url,
        reply_to: message_data['message']&.[]('reply_to')&.[]('mid'),
        filename: file_name
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
      attachment = response['attachments']&.[]('data')&.[](0)
      file_type = attachment&.[]('mime_type')
      file_name = attachment&.[]('name')
      attachment_url = grab_url(response, file_type)
      message = @klass.create_with(
        customer: customer,
        facebook_retailer: @facebook_retailer,
        sender_uid: @facebook_retailer.uid,
        id_client: psid,
        file_type: file_type,
        url: attachment_url,
        text: response['message'],
        filename: file_name
      ).find_or_create_by(mid: response['id'])
      return unless attachment_url && message.url.nil?

      message.update(
        url: attachment_url,
        file_type: file_type,
        filename: message.filename.presence || file_name
      )
    end

    def send_message(to, message)
      url = send_message_url
      conn = Connection.prepare_connection(url)
      response = Connection.post_request(conn, prepare_message(to, message))
      JSON.parse(response.body)
    end

    def send_attachment(to, file_data, filename, url = nil, file_type = nil, file_content_type = nil)
      conn = Faraday.new(send_message_url) do |f|
        f.request :multipart
        f.request :url_encoded
        f.adapter :net_http
        f.response :logger, Logger.new(STDOUT), bodies: true
      end
      response = Connection.post_form_request(conn, prepare_attachment(to, file_data, filename, url, file_type,
        file_content_type))
      JSON.parse(response.body)
    end

    def mark_read(psid)
      customer = Customer.find_by(psid: psid)
      return unless customer.present?

      messages = customer.message_records.where.not(note: true).retailer_unread.order(:id)
      last_message = messages.last
      return unless last_message.present?

      read_date = Time.now
      messages.update_all(date_read: read_date)

      facebook_helper = FacebookNotificationHelper
      retailer = @facebook_retailer.retailer
      last_message.date_read = read_date
      agents = customer.agent.present? ? [customer.agent] : retailer.retailer_users.all_customers.to_a
      facebook_helper.broadcast_data(retailer, agents, last_message, customer.agent_customer, nil, @type)
    end

    def send_read_action(to, action)
      url = send_message_url
      conn = Connection.prepare_connection(url)
      Connection.post_request(conn, prepare_action(to, action))
    end

    def send_bulk_files(customer, retailer_user, params)
      Facebook::Api.new(@facebook_retailer, retailer_user, @type).send_bulk_files(customer, params)
    end

    def save_postback_interaction(message_data)
      customer = Facebook::Customers.new(@facebook_retailer).import(message_data['sender']['id'])

      @klass.create(
        customer: customer,
        facebook_retailer: @facebook_retailer,
        sender_uid: message_data['sender']['id'],
        id_client: message_data['sender']['id'],
        text: message_data['postback']&.[]('payload')
      )
    end

    private

      def sniff_mime_type(url)
        open(url).content_type.first(5)
      end

      def add_human_agent_tag(psid, body)
        last_message_date = Customer.find_by(psid: psid).facebook_messages.inbound.last&.created_at
        if @type == 'instagram' || (last_message_date && last_message_date <= 24.hours.ago)
          body.merge!("messaging_type": 'MESSAGE_TAG', "tag": 'HUMAN_AGENT')
        end
        body
      end

      def prepare_message(to, message)
        body = {
          "recipient": {
            "id": to
          },
          "message": {
            "text": message
          }
        }
        body = add_human_agent_tag(to, body)
        body.to_json
      end

      def prepare_attachment(to, file_path, filename, url = nil, file_type = nil, file_content_type = nil)
        body = if file_path.present?
                 content_type = file_content_type.presence || MIME::Types.type_for(file_path).first.content_type
                 type = check_content_type(content_type)

                 {
                   "recipient": JSON.dump(id: to),
                   "message": JSON.dump(attachment: {
                     "type": type,
                     "payload": {}
                   }),
                   "filedata": Faraday::UploadIO.new(file_path, content_type, filename)
                 }
               else
                 {
                   'recipient': {
                     'id': to
                   },
                   'message': {
                     'attachment': {
                       'type': file_type,
                       'payload': {
                         'url': url
                       }
                     }
                   }
                 }
               end
        body = add_human_agent_tag(to, body)
        body
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

      def fallback_url(url)
        post_id = CGI.parse(URI.parse(url).query)['story_fbid'][0]
        params = {
          fields: 'message,child_attachments,attachments{media,subattachments}',
          access_token: @facebook_retailer.access_token
        }
        "https://graph.facebook.com/v11.0/#{@facebook_retailer.uid}_#{post_id}?#{params.to_query}"
      rescue
        nil
      end

      def check_content_type(content_type)
        return unless content_type.present?
        return 'image' if content_type.include?('image/')
        'file' if right_file_format?(content_type)
      end

      def grab_url(response, content_type)
        type = check_content_type(content_type)
        return unless type.present?

        attachment = response['attachments']&.[]('data')&.[](0)
        return attachment&.[]('image_data')&.[]('url') if type == 'image'

        attachment&.[]('file_url')
      end

      def prepare_action(to, action)
        body = {
          'recipient': {
            'id': to
          },
          'sender_action': action
        }
        body = add_human_agent_tag(to, body)
        body.to_json
      end

      def file_type_url(message_data, file_type)
        return unless file_type

        case file_type
        when 'location', 'fallback'
          message_data['message']&.[]('attachments')&.[](0)&.[]('url') ||
            message_data['message']&.[]('attachments')&.[](0)&.[]('payload')&.[]('url')
        else
          message_data['message']&.[]('attachments')&.[](0)&.[]('payload')&.[]('url')
        end
      end

      def get_fallback_media_url(url)
        post_url = fallback_url(url)
        return [url, 'fallback'] if post_url.nil?

        response = JSON.parse(Faraday.get(post_url).body)
        video_url = response['attachments']['data'][0]['media']['source']
        if video_url
          [video_url, 'video']
        else
          [response['attachments']['data'][0]['media']['image']['src'], 'image']
        end
      rescue
        [url, 'fallback']
      end

      def right_file_format?(content_type)
        [
          'application/pdf',
          'application/msword',
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          'application/vnd.ms-excel'
        ].include?(content_type)
      end
  end
end
