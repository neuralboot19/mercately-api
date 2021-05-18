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

        Cloudinary::Uploader.upload(
          file,
          api_key: ENV['CLOUDINARY_API_KEY'],
          timestamp: timestamp,
          signature: Cloudinary::Utils.api_sign_request(params_to_sign, ENV['CLOUDINARY_API_SECRET']),
          resource_type: cloudinary_resource_type(resource_type),
          use_filename: true
        )
      end

      def get_resource_type(file)
        content_type = MIME::Types.type_for(file.tempfile.path).first.content_type
        return unless content_type.present?
        return 'image' if content_type.include?('image')
        return 'document' if ['application/pdf', 'application/msword',
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          'application/vnd.ms-excel'].include?(content_type)
      end

      def cloudinary_resource_type(resource_type)
        return 'image' if resource_type == 'image'
        return 'video' if ['audio', 'voice', 'video'].include?(resource_type)

        'raw'
      end
    end
  end
end
