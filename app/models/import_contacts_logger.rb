class ImportContactsLogger < ApplicationRecord
  belongs_to :retailer
  belongs_to :retailer_user

  has_one_attached :file

  def file_url
    if file.content_type == 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      "https://res.cloudinary.com/#{ENV['CLOUDINARY_CLOUD_NAME']}/raw/upload/#{self.file.key}.xlsx"
    elsif file.content_type == 'text/csv'
      "https://res.cloudinary.com/#{ENV['CLOUDINARY_CLOUD_NAME']}/raw/upload/#{self.file.key}.csv"
    end
  end

  def delete_file
    params_to_sign = {
      timestamp: Time.now.to_i
    }

    extension = if file.content_type == 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
                  '.xlsx'
                elsif file.content_type == 'text/csv'
                  '.csv'
                end

    result = Cloudinary::Uploader.destroy(
      "#{file.key}#{extension}",
      signature: Cloudinary::Utils.api_sign_request(params_to_sign, ENV['CLOUDINARY_API_SECRET']),
      resource_type: 'raw'
    )

    file.purge if result&.[]('result') == 'ok'
  end
end
