module Whatsapp::Gupshup::V1
  class Outbound::Msg < Base

    SM_URL = "#{GUPSHUP_BASE_URL}/msg"
    TEMPLATE_URL = "#{GUPSHUP_BASE_URL}/template/msg"

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

      # Stores the Gupshup Whatsapp Message in our DB
      message = save_message(response.code, response_body, request_body, @options[:retailer_user])

      # Returns the Gupshup response
      {
        code: response.code,
        body: response_body,
        message: message
      }
    rescue StandardError => e
      Rails.logger.error(e)
    end

    def send_bulk_files(options)
      @phone_number = @customer.phone_number(false)
      @options = options

      iteration_param = @options[:params][:url].present? ? [@options[:params][:url]] : @options[:params][:file_data]
      unless iteration_param
        raise StandardError.new('Faltaron parámetros')
      end
      iteration_param&.each_with_index do |file, index|
        @index = index
        request_body = self.send(@options[:type])
        response = send_message_request(request_body[0])
        response_body = JSON.parse(response.read_body)
        save_message(response.code, response_body, request_body, @options[:retailer_user])
      end
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
        raise StandardError.new('Faltaron parámetros') unless complete_template_params?

        body_string = base_body
        message = {
          isHSM: 'true',
          type: 'text',
          text: @options[:params][:message]
        }

        if @options[:params][:gupshup_template_id].present?
          @is_template_with_id = true

          message[:id] = @options[:params][:gupshup_template_id]
          message[:params] = @options[:params][:template_params].presence || []

          except = [:isHSM, :type, :text]
          aux_message = message.except(*except).to_json
          message = message.to_json
          body_string += "&template=#{aux_message}"
        else
          message = message.to_json
          body_string += "&message=#{CGI.escape(message)}"
        end

        [body_string, message]
      end

      # Send Text
      def text
        raise StandardError.new('Faltaron parámetros') unless @options[:params]&.[](:message).present?

        message = {
          'isHSM': 'false',
          'type': 'text',
          'text': @options[:params][:message]
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
          'caption': data[:file_caption] || ''
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

      def document_template(file_url:, file_name:, file_caption:)
        message = {
          isHSM: 'true',
          type: 'file',
          url: file_url,
          caption: file_caption,
          filename: file_name
        }.to_json

        bodyString = base_body
        bodyString += "&message=#{CGI.escape(message)}"

        [bodyString, message]
      end


      # Send Audio
      def audio(data)
        raise StandardError.new('Faltaron parámetros') unless data[:file_url].present?

        index = data[:file_url].rindex('.')
        url = data[:file_url][0, index]
        url += '.aac'

        fd_response = Faraday.get url
        Rails.logger.info "GETTING #{url} and RESPONSE::: #{fd_response.status}"

        message = {
          'type': 'audio',
          'url': url
        }.to_json

        bodyString = base_body
        bodyString += "&message=#{CGI.escape(message)}"

        [bodyString, message]
      end

      # Send Video
      def video(data)
        raise StandardError.new('Faltaron parámetros') unless data[:file_url].present?

        message = {
          'type': 'video',
          'url': data[:file_url],
          'caption': data[:file_caption]
        }.to_json

        bodyString = base_body
        bodyString += "&message=#{CGI.escape(message)}"

        [bodyString, message]
      end

      # Send Location
      def location
        unless @options[:params]&.[](:longitude).present? &&
               @options[:params]&.[](:latitude).present?
          raise StandardError.new('Faltaron parámetros')
        end

        message = {
          'type': 'location',
          'longitude': @options[:params][:longitude],
          'latitude': @options[:params][:latitude]
        }.to_json

        bodyString = base_body
        bodyString += "&message=#{CGI.escape(message)}"

        [bodyString, message]
      end

      def save_message(response_status, response_body, request_body, retailer_user)
        gwm = @retailer.gupshup_whatsapp_messages.new(
          customer: @customer,
          direction: 'outbound',
          source: @retailer.phone_number,
          destination: @phone_number,
          channel: 'whatsapp',
          retailer_user: retailer_user
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
        gwm
      rescue => e
        Rails.logger.error(e)
      end

      def send_message_request(body)
        @retailer.with_advisory_lock(@retailer.to_global_id.to_s) do
          url = @is_template_with_id ? TEMPLATE_URL : SM_URL
          post(url, body)
        end
      end

      def file
        is_document_template = @options[:params][:type] == 'file' && @options[:params][:template] == 'true'

        if @options[:params][:file_data].present?
          file = @index ? @options[:params][:file_data][@index] : @options[:params][:file_data]
          resource_type = get_resource_type(file)
          response = Whatsapp::Karix::Api.new.upload_file_to_cloudinary(
            file,
            resource_type
          )

          file_name = ['document_template', 'document'].include?(resource_type) ? response['original_filename'] : ''
          file_name = file_name.parameterize
          file_name += '.pdf' if resource_type == 'document_template'
          file_url = response['secure_url'] || response['url']
          file_caption = is_document_template ? @options[:params][:caption] || '' : ''
        elsif @options[:params][:url].present?
          resource_type = is_document_template ? 'document_template' : check_type_on_url
          file_name = @options[:params][:file_name].present? ? @options[:params][:file_name] : ''
          file_url = @options[:params][:url]
          file_caption = @options[:params][:caption] || ''
        end

        self.send(resource_type, {
          file_name: file_name,
          file_url: file_url,
          file_caption: file_caption
        })
      end

      def get_resource_type(uploaded_file)
        return 'document_template' if @options[:params][:type] == 'file' && @options[:params][:template] == 'true'
        return 'audio' if ['audio', 'voice'].include?(@options[:params][:type])

        content_type = MIME::Types.type_for(uploaded_file.tempfile.path).first.content_type
        return unless content_type.present?
        get_resource_from_content_type content_type
      end

      def get_resource_from_content_type(content_type)
        return 'image' if content_type.include?('image')
        return 'video' if content_type.include?('video')

        'document' if ['application/pdf', 'application/msword',
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document'].include?(content_type)
      end

      def check_type_on_url
        return 'audio' if ['audio', 'voice'].include?(@options[:params][:type])

        @options[:params][:content_type].present? ?
          get_resource_from_content_type(@options[:params][:content_type]) : 'image'
      end

      def complete_template_params?
        @options[:params]&.[](:message).present? || @options[:params]&.[](:gupshup_template_id).present?
      end
  end
end
