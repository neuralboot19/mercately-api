class AdditionalFastAnswer < ApplicationRecord
  belongs_to :template
  has_one_attached :file

  attribute :file_deleted, :boolean

  def file_url
    "https://res.cloudinary.com/#{ENV['CLOUDINARY_CLOUD_NAME']}/image/upload/#{file.key}"
  end
end
