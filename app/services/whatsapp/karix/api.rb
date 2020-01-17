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
            customer.phone
          ],
          content: {
            text: params[:message]
          },
          events_url: ENV['KARIX_WEBHOOK']
        }.to_json
      end

      def prepare_whatsapp_message_file(retailer, customer, params)
        resource_type = get_resource_type(params[:file_data])
        upload_url = cloudinary_upload_file_url(resource_type)
        response = upload_file_to_cloudinary(params[:file_data])

        {
          channel: 'whatsapp',
          source: retailer.karix_whatsapp_phone,
          destination: [
            customer.phone
          ],
          content: {
            media: {
              url: response['secure_url'] || response['url'],
              caption: params[:caption]
            }
          },
          events_url: ENV['KARIX_WEBHOOK']
        }.to_json
      end

      def cloudinary_upload_file_url(resource_type)
        "https://api.cloudinary.com/v1_1/#{ENV['CLOUDINARY_CLOUD_NAME']}/#{resource_type}/upload"
      end

      def upload_file_to_cloudinary(file)
        timestamp = Time.now.to_i

        params_to_sign = {
          timestamp: timestamp
        }

        Cloudinary::Uploader.upload(
          file,
          api_key: ENV['CLOUDINARY_API_KEY'],
          timestamp: timestamp,
          signature: Cloudinary::Utils.api_sign_request(params_to_sign, ENV['CLOUDINARY_API_SECRET'])
        )
      end

      def get_resource_type(file)
        content_type = MIME::Types.type_for(file.tempfile.path).first.content_type
        return 'image' if content_type&.include?('image')
      end
    end
  end
end
