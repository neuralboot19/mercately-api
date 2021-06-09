class InstagramMessage < ApplicationRecord
  include FacebookMessages

  before_create :upload_file_to_cloudinary
  before_create :save_url

  private

    def upload_file_to_cloudinary
      return if file_data.blank?

      timestamp = Time.now.to_i
      params_to_sign = {
        timestamp: timestamp
      }
      response = Cloudinary::Uploader.upload(
        file_data,
        api_key: ENV['CLOUDINARY_API_KEY'],
        timestamp: timestamp,
        signature: Cloudinary::Utils.api_sign_request(params_to_sign, ENV['CLOUDINARY_API_SECRET']),
        resource_type: 'image',
        use_filename: true
      )
      self.file_url = response['secure_url'] || response['url']
      self.file_type = 'image'
      self.file_data = nil if file_url.present?
    end

    def save_url
      return if file_url.blank?

      self.url = file_url.dup
    end
end
