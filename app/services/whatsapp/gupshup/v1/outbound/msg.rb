module Whatsapp::Gupshup::V1
  class Outbound::Msg < Base

    SM_URL = "#{GUPSHUP_BASE_URL}/msg"

    def send_message(options)
      @phone_number = @customer.phone_number(false)
      @options = options

      # Prepares the body depending on the type of message to send
      # it could be template, text, image, document, audio, video
      # or location
      request_body = self.send(@options[:type])
      # Makes the request to Gupshup for sending the whatsapp message
      response = send_message_request(request_body[0])
      response_body = JSON.parse(response.read_body)

      # Stores the Gupshup Whatsapp Meesage in our DB
      save_message(response.code, response_body, request_body)

      # Returns the Gupshup response
      {
        code: response.code,
        body: response_body
      }
    rescue StandardError => e
      Rails.logger.error(e)
    end

    private

      def base_body
        unless @retailer.gupshup_phone_number.present?
          raise StandardError.new('Faltaron parámetros')
        end

        bodyString = 'channel=whatsapp' \
                     "&source=#{@retailer.whatsapp_phone_number(false)}" \
                     "&destination=#{@phone_number}"
        bodyString += "&src.name=#{@retailer.gupshup_src_name}" if @retailer.gupshup_src_name.present?

        bodyString
      end

      # Send Template Message
      def template
        raise StandardError.new('Faltaron parámetros') unless @options[:text].present?

        message = {
          'isHSM':'true',
          'type': 'text',
          'text': @options[:text]
        }.to_json

        bodyString = base_body
        bodyString += "&message=#{CGI.escape(message)}"

        [bodyString, message]
      end

      # Send Text
      def text
        raise StandardError.new('Faltaron parámetros') unless @options[:text].present?

        message = {
          'isHSM': 'false',
          'type': 'text',
          'text': @options[:text]
        }.to_json

        bodyString = base_body
        bodyString += "&message=#{CGI.escape(message)}"

        [bodyString, message]
      end

      # Send Image
      def image(data)
        raise StandardError.new('Faltaron parámetros') unless data[:file_url].present?

        message = {
          'type': 'image',
          'originalUrl': data[:file_url],
          'previewUrl': data[:file_url],
          'caption': ''
        }.to_json

        bodyString = base_body
        bodyString += "&message=#{CGI.escape(message)}"

        [bodyString, message]
      end

      # Send Document/File
      def document(data)
        unless data[:file_url].present? && data[:file_name].present?
          raise StandardError.new('Faltaron parámetros')
        end
        message = {
          'type': 'file',
          'url': data[:file_url],
          'filename': data[:file_name]
        }.to_json

        bodyString = base_body
        bodyString += "&message=#{CGI.escape(message)}"

        [bodyString, message]
      end

      # Send Audio
      def audio
        raise StandardError.new('Faltaron parámetros') unless @options[:file_url].present?

        message = {
          'type': 'audio',
          'url': @options[:file_url]
        }.to_json

        bodyString = base_body
        bodyString += "&message=#{CGI.escape(message)}"

        [bodyString, message]
      end

      # Send Video
      def video
        raise StandardError.new('Faltaron parámetros') unless @options[:video_url].present?

        message = {
          'type': 'video',
          'url': @options[:video_url],
          'caption': ''
        }.to_json

        bodyString = base_body
        bodyString += "&message=#{CGI.escape(message)}"

        [bodyString, message]
      end

      # Send Location
      def location
        unless @options[:lon].present? &&
               @options[:lat].present? &&
               @options[:name].present? &&
               @options[:addr].present?
          raise StandardError.new('Faltaron parámetros')
        end

        message = {
          'type': 'location',
          'longitude': @options[:lon].to_f.round(2),
          'latitude': @options[:lat].to_f.round(2),
          'name': @options[:name],
          'address': @options[:addr]
        }.to_json

        bodyString = base_body
        bodyString += "&message=#{CGI.escape(message)}"

        [bodyString, message]
      end

      def save_message(response_status, response_body, request_body)
        gwm = @retailer.gupshup_whatsapp_messages.new(
          customer: @customer,
          direction: 'outbound',
          source: @retailer.phone_number,
          destination: @phone_number,
          channel: 'whatsapp'
        )

        if response_status.to_i == 200
          gwm.gupshup_message_id = response_body['messageId']
          gwm.status = 'sent'
          gwm.message_payload = JSON.parse(request_body[1])
        else
          gwm.status = :error
          gwm.error_payload = response_body
        end

        gwm.save!
      rescue => e
        Rails.logger.error(e)
      end

      def send_message_request(body)
        @retailer.with_advisory_lock(@retailer.to_global_id.to_s) do
          post(SM_URL, body)
        end
      end

      def file
        resource_type = get_resource_type(@options[:params][:file_data])
        response = Whatsapp::Karix::Api.new().upload_file_to_cloudinary(
          @options[:params][:file_data],
          resource_type
        )

        file_name = resource_type == 'document' ? response['original_filename'] : ''
        file_url = response['secure_url'] || response['url']

        self.send(resource_type, {
          file_name: file_name,
          file_url: file_url
        })
      end

      def get_resource_type(uploaded_file)
        content_type = MIME::Types.type_for(uploaded_file.tempfile.path).first.content_type
        return unless content_type.present?
        return 'image' if content_type.include?('image')
        return 'document' if ['application/pdf', 'application/msword',
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document'].include?(content_type)
      end
  end
end
