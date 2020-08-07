class GupshupWhatsappMessageSerializer
  include FastJsonapi::ObjectSerializer

  set_type :gupshup_whatsapp_message
  set_id :id

  attributes :id, :retailer_id, :customer_id, :status, :direction, :channel, :message_type, :uid, :created_time,
             :replied_message

  attribute :content_type do |object|
    message = object.message_payload
    type = message.try(:[], 'payload').try(:[], 'type') || message['type']
    type = message.try(:[], 'type') if type.blank?
    next 'text' if type == 'text'
    next 'media' if %[image audio video file].include?(type)
    next 'location' if type == 'location'
    next 'contact' if type == 'contact'
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

    url = message.try(:[], 'originalUrl') ||
      message.try(:[], 'payload').try(:[], 'payload').try(:[],'url') ||
      message.try(:[], 'url') || ''

    url.gsub('http:', 'https:')
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
    type = (object.direction == 'inbound' ? message.try(:[], 'payload').try(:[], 'type') : message.try(:[], 'type')) ||
      message['type']
    next '' unless type == 'location'
    object.direction == 'inbound' ? message['payload']['payload']['longitude'] : message['longitude']
  end

  attribute :content_location_latitude do |object|
    message = object.message_payload
    type = (object.direction == 'inbound' ? message.try(:[], 'payload').try(:[], 'type') : message.try(:[], 'type')) ||
      message['type']
    next '' unless type == 'location'
    object.direction == 'inbound' ? message['payload']['payload']['latitude'] : message['latitude']
  end

  attribute :content_location_label do |object|
    message = object.message_payload
    type = (object.direction == 'inbound' ? message.try(:[], 'payload').try(:[], 'type') : message.try(:[], 'type')) ||
      message['type']
    next '' unless type == 'location'
    message['name']
  end

  attribute :content_location_address do |object|
    message = object.message_payload
    type = (object.direction == 'inbound' ? message.try(:[], 'payload').try(:[], 'type') : message.try(:[], 'type')) ||
      message['type']
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

  attribute :created_time do |object|
    object.created_at
  end

  attribute :contacts_information do |object|
    message = object.message_payload
    type = message.try(:[], 'payload').try(:[], 'type') || message['type']
    next [] unless type == 'contact'

    info = []
    contacts = message.try(:[], 'payload').try(:[], 'payload').try(:[], 'contacts') || []

    contacts.each do |c|
      info << {
        names: c['name'],
        phones: c['phones'],
        emails: c['emails'],
        addresses: c['addresses'],
        org: c['org']
      }
    end

    info
  end

  attribute :replied_message do |object|
    message = object.message_payload
    id = message.try(:[], 'payload').try(:[], 'context').try(:[], 'id')
    next unless id.present?

    replied = GupshupWhatsappMessage.find_by_whatsapp_message_id(id)
    next unless replied

    JSON.parse(
      GupshupWhatsappMessageSerializer.new(
        replied
      ).serialized_json
    )
  end
end
