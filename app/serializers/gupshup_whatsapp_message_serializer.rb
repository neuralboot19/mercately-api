class GupshupWhatsappMessageSerializer
  include FastJsonapi::ObjectSerializer

  set_type :gupshup_whatsapp_message
  set_id :id

  attributes :id, :retailer_id, :customer_id, :status, :direction, :channel, :message_type, :uid

  attribute :content_type do |object|
    message = object.message_payload
    type = message.try(:[], 'payload').try(:[], 'type') || message['type']
    next 'text' if type == 'text'
    next 'media' if %[image audio video file].include?(type)
    'location'
  end

  attribute :content_text do |object|
    message = object.message_payload
    type = message.try(:[], 'payload').try(:[], 'type') || message['type']
    next '' unless type == 'text'
    message['payload'].try(:[], 'payload').try(:[], 'text') || message['text']
  end

  attribute :content_media_url do |object|
    message = object.message_payload
    type = message.try(:[], 'payload').try(:[], 'type') || message['type']
    next '' unless %[image audio video file].include?(type)

    message.try(:[], 'originalUrl') ||
    message.try(:[], 'payload').try(:[], 'payload').try(:[],'url') ||
    message.try(:[], 'url') ||
    ''
  end

  attribute :content_media_caption do |object|
    message = object.message_payload
    type = message.try(:[], 'payload').try(:[], 'type') || message['type']
    next '' unless %[image audio video file].include?(type)

    message.try(:[], 'caption') ||
    message.try(:[], 'filename') ||
    message.try(:[], 'url') ||
    ''
  end

  attribute :content_media_type do |object|
    message = object.message_payload
    type = message.try(:[], 'payload').try(:[], 'type') || message['type']
    next '' if type == 'text'
    next 'document' if type == 'file'
    type
  end

  attribute :content_location_longitude do |object|
    message = object.message_payload
    type = message.try(:[], 'payload').try(:[], 'type') || message['type']
    next '' unless type == 'location'
    message['payload']['payload']['longitude']
  end

  attribute :content_location_latitude do |object|
    message = object.message_payload
    type = message.try(:[], 'payload').try(:[], 'type') || message['type']
    next '' unless type == 'location'
    message['payload']['payload']['latitude']
  end

  attribute :content_location_label do |object|
    message = object.message_payload
    type = message.try(:[], 'payload').try(:[], 'type') || message['type']
    next '' unless type == 'location'
    message['name']
  end

  attribute :content_location_address do |object|
    message = object.message_payload
    type = message.try(:[], 'payload').try(:[], 'type') || message['type']
    next '' unless type == 'location'
    message['address']
  end

  attribute :status do |object|
    object.status.to_s
  end

  attribute :account_uid do |object|
    object.gupshup_message_id
  end

  attribute :uid do |object|
    object.gupshup_message_id
  end

  attribute :message_type do |object|
    'conversation'
  end
end
