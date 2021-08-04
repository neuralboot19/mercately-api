class FacebookMessageSerializer < ActiveModel::Serializer
  attributes :id, :customer_id, :text, :created_at, :date_read, :sent_by_retailer, :file_type,
             :filename, :sent_from_mercately, :mid, :message_identifier, :url, :sender_full_name

  def url
    object.url&.gsub('http:', 'https:')
  end

  def sender_full_name
    return if object.sent_from_mercately == false || object.retailer_user_id.blank?

    full_name = "#{object.sender_first_name} #{object.sender_last_name}".strip
    full_name.presence || object.sender_email
  end
end
