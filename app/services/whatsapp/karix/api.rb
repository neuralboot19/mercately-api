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

      def prepare_whatsapp_message_file(retailer, customer, params)
        if params[:file_data].present?
          resource_type = get_resource_type(params[:file_data])
          response = upload_file_to_cloudinary(params[:file_data], resource_type)
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
    end
  end
end
