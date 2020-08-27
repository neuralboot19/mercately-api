require 'mime/types'

module Whatsapp
  module Karix
    class Api
      def prepare_send_whatsapp_message_url
        'https://api.karix.io/message/'
      end

      def prepare_whatsapp_message_text(retailer, customer, params)
        {
          channel: 'whatsapp',
          source: retailer.karix_whatsapp_phone,
          destination: [
            params[:phone_number] || customer.phone
          ],
          content: {
            text: params[:message]
          },
          events_url: "#{ENV['KARIX_WEBHOOK']}?account_id=#{retailer.id}"
        }.to_json
      end

      def prepare_whatsapp_message_file(retailer, customer, params, index = nil)
        if params[:file_data].present?
          file = index ? params[:file_data][index] : params[:file_data]
          resource_type = get_resource_type(file)
          response = upload_file_to_cloudinary(file, resource_type)
          filename = response['original_filename'] if resource_type == 'document'

          url = response['secure_url'] || response['url']
          caption = params[:caption] || filename
        elsif params[:url].present?
          url = params[:url]
          caption = params[:caption] || ''
        end

        {
          channel: 'whatsapp',
          source: retailer.karix_whatsapp_phone,
          destination: [
            customer.phone
          ],
          content: {
            media: {
              url: url,
              caption: caption
            }
          },
          events_url: "#{ENV['KARIX_WEBHOOK']}?account_id=#{retailer.id}"
        }.to_json
      end

      def prepare_whatsapp_message_location(retailer, customer, params)
        {
          channel: 'whatsapp',
          source: retailer.karix_whatsapp_phone,
          destination: [
            customer.phone
          ],
          content: {
            location: {
              longitude: params[:longitude].round(7).to_s,
              latitude: params[:latitude].round(7).to_s,
              label: ''
            }
          },
          events_url: "#{ENV['KARIX_WEBHOOK']}?account_id=#{retailer.id}"
        }.to_json
      end

      def upload_file_to_cloudinary(file, resource_type)
        timestamp = Time.now.to_i

        params_to_sign = {
          timestamp: timestamp
        }

        public_id = File.basename(file.original_filename) if resource_type == 'document'

        Cloudinary::Uploader.upload(
          file,
          public_id: public_id,
          api_key: ENV['CLOUDINARY_API_KEY'],
          timestamp: timestamp,
          signature: Cloudinary::Utils.api_sign_request(params_to_sign, ENV['CLOUDINARY_API_SECRET']),
          resource_type: resource_type == 'image' ? 'image' : 'raw'
        )
      end

      def get_resource_type(file)
        content_type = MIME::Types.type_for(file.tempfile.path).first.content_type
        return unless content_type.present?
        return 'image' if content_type.include?('image')
        return 'document' if ['application/pdf', 'application/msword',
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document'].include?(content_type)
      end

      def prepare_welcome_message_body(retailer)
        message = 'Bienvenido a Mercately.com, centralizamos tus canales de ventas y comunicación.'
        message += 'Si necesitas ayuda no dudes en contactarnos.'
        sender = Retailer.find_by(karix_whatsapp_phone: '+593989083446')

        {
          channel: 'whatsapp',
          source: sender.karix_whatsapp_phone,
          destination: [
            retailer.retailer_number
          ],
          content: {
            text: message
          },
          events_url: "#{ENV['KARIX_WEBHOOK']}?account_id=#{sender.id}"
        }.to_json
      end

      def prepare_chat_bot_message(chat_bot_option, get_out = false, error_exit = false)
        return unless chat_bot_option.present?

        if get_out == false && error_exit == false
          message = chat_bot_option.answer + "\n\n"

          children = chat_bot_option.children.active
          if children.present?
            children.order(:position).each do |child|
              message += (child.position.to_s + '. ' + child.text + "\n")
            end
          end
        else
          message = get_out ? chat_bot_option.chat_bot.goodbye_message : chat_bot_option.chat_bot.error_message
        end

        message
      end
    end
  end
end
