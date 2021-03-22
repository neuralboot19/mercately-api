class AdditionalBotAnswer < ApplicationRecord
  belongs_to :chat_bot_option

  has_one_attached :file

  attribute :file_deleted, :boolean

  def file_url
    if file.content_type.include?('video/')
      "https://res.cloudinary.com/#{ENV['CLOUDINARY_CLOUD_NAME']}/video/upload/#{self.file.key}"
    else
      "https://res.cloudinary.com/#{ENV['CLOUDINARY_CLOUD_NAME']}/image/upload/#{self.file.key}"
    end
  end

  def file_type
    return unless file.attached?
    return 'image' if file.content_type.include?('image/')
    return 'file' if file.content_type == 'application/pdf'

    'video' if file.content_type.include?('video/')
  end
end
