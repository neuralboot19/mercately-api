class KarixWhatsappMessageSerializer < ActiveModel::Serializer
  attributes :id, :customer_id, :uid, :account_uid, :source, :destination, :country, :content_type, :content_text,
             :content_media_type, :content_location_longitude,
             :content_location_latitude, :content_location_label, :content_location_address, :created_time,
             :sent_time, :delivered_time, :updated_time, :status, :direction, :channel, :error_code, :error_message,
             :message_identifier, :content_media_url, :filename, :content_media_caption, :sender_full_name

  def content_media_url
    object.content_media_url&.gsub('http:', 'https:')
  end

  def filename
    return object.content_media_caption if object.content_media_type == 'document'

    ''
  end

  def content_media_caption
    return '' if object.content_media_type == 'document'

    object.content_media_caption
  end

  def sender_full_name
    return if object.direction == 'inbound' || object.retailer_user_id.blank?

    full_name = "#{object.sender_first_name} #{object.sender_last_name}".strip
    full_name.presence || object.sender_email
  end
end
