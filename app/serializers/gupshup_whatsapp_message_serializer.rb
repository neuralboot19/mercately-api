class GupshupWhatsappMessageSerializer
  include FastJsonapi::ObjectSerializer

  set_type :gupshup_whatsapp_message
  set_id :id

  attributes :id, :retailer_id, :customer_id, :status, :direction, :channel, :message_type, :message_identifier,
             :uid, :created_time, :replied_message, :filename, :sender_full_name, :will_retry

  attribute :content_type do |gwm|
    message = gwm.message_payload
    type = message.try(:[], 'payload').try(:[], 'type') || message['type']
    type = message.try(:[], 'type') if type.blank?
    next 'text' if ['text', 'quick_reply'].include?(type) && !gwm.has_referral_media?
    next 'media' if %[image audio video file sticker].include?(type) || gwm.has_referral_media?
    next 'location' if type == 'location'
    next 'contact' if type == 'contact'
  end

  attribute :content_text do |gwm|
    message = gwm.message_payload
    type = message.try(:[], 'payload').try(:[], 'type') || message['type']
    next '' unless ['text', 'quick_reply'].include?(type)

    msg = message['payload'].try(:[], 'payload').try(:[], 'text') || message['text']
    msg += " #{message['payload'].try(:[], 'referral').try(:[], 'source_url')}" if gwm.has_referral?

    msg
  end

  attribute :content_media_url do |gwm|
    message = gwm.message_payload
    with_media = gwm.has_referral_media?
    type = message.try(:[], 'payload').try(:[], 'type') || message['type']
    next '' unless %[image audio video file sticker].include?(type) || with_media

    url = if with_media
            "https://filemanager.gupshup.io/fm/wamedia/#{gwm.retailer.gupshup_src_name.strip}/#{gwm.referral_media_id}"
          else
            message.try(:[], 'originalUrl') ||
              message.try(:[], 'payload').try(:[], 'payload').try(:[],'url') ||
              message.try(:[], 'url') || ''
          end

    url.gsub('http:', 'https:')
  end

  attribute :content_media_caption do |gwm|
    message = gwm.message_payload
    with_media = gwm.has_referral_media?
    type = message.try(:[], 'payload').try(:[], 'type') || message['type']
    next '' unless %[image audio video file sticker].include?(type) || with_media

    caption = if with_media
                "#{message['payload'].try(:[], 'payload').try(:[], 'text') || message['text']} " \
                  "#{message['payload'].try(:[], 'referral').try(:[], 'source_url')}"
              elsif %[image audio video sticker].include?(type) ||
                (type == 'file' && gwm.message_type == 'notification')
                message.try(:[], 'caption') ||
                  message.try(:[], 'payload').try(:[], 'payload').try(:[],'caption')
              end

    caption || ''
  end

  attribute :content_media_type do |gwm|
    message = gwm.message_payload
    with_media = gwm.has_referral_media?
    type = message.try(:[], 'payload').try(:[], 'type') || message['type']
    next '' if type == 'text' && !with_media
    next gwm.referral_type_media if with_media
    next 'document' if type == 'file'

    type
  end

  attribute :content_location_longitude do |gwm|
    message = gwm.message_payload
    type = (gwm.direction == 'inbound' ? message.try(:[], 'payload').try(:[], 'type') : message.try(:[], 'type')) ||
      message['type']
    next '' unless type == 'location'
    gwm.direction == 'inbound' ? message['payload']['payload']['longitude'] : message['longitude']
  end

  attribute :content_location_latitude do |gwm|
    message = gwm.message_payload
    type = (gwm.direction == 'inbound' ? message.try(:[], 'payload').try(:[], 'type') : message.try(:[], 'type')) ||
      message['type']
    next '' unless type == 'location'
    gwm.direction == 'inbound' ? message['payload']['payload']['latitude'] : message['latitude']
  end

  attribute :content_location_label do |gwm|
    message = gwm.message_payload
    type = (gwm.direction == 'inbound' ? message.try(:[], 'payload').try(:[], 'type') : message.try(:[], 'type')) ||
      message['type']
    next '' unless type == 'location'
    message['name']
  end

  attribute :content_location_address do |gwm|
    message = gwm.message_payload
    type = (gwm.direction == 'inbound' ? message.try(:[], 'payload').try(:[], 'type') : message.try(:[], 'type')) ||
      message['type']
    next '' unless type == 'location'
    message['address']
  end

  attribute :status do |gwm|
    gwm.status.to_s
  end

  attribute :account_uid do |gwm|
    gwm.gupshup_message_id
  end

  attribute :uid do |gwm|
    gwm.gupshup_message_id
  end

  attribute :message_type do |gwm|
    'conversation'
  end

  attribute :created_time do |gwm|
    gwm.created_at
  end

  attribute :contacts_information do |gwm|
    message = gwm.message_payload
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

  attribute :replied_message do |gwm|
    message = gwm.message_payload
    id = message.try(:[], 'payload').try(:[], 'context').try(:[], 'id')
    gs_id = message.try(:[], 'payload').try(:[], 'context').try(:[], 'gsId')
    next unless id.present? || gs_id.present?

    customer = Customer.find_by(id: gwm.customer_id)
    next unless customer.present?

    replied = customer.gupshup_whatsapp_messages.find_by_whatsapp_message_id(id).presence ||
      customer.gupshup_whatsapp_messages.find_by_gupshup_message_id(gs_id)

    next unless replied.present?

    JSON.parse(
      GupshupWhatsappMessageSerializer.new(
        replied
      ).serialized_json
    )
  end

  attribute :filename do |gwm|
    message = gwm.message_payload
    type = message.try(:[], 'payload').try(:[], 'type') || message['type']
    next '' unless type == 'file'

    next message.try(:[], 'filename') || message.try(:[], 'payload').try(:[], 'payload').try(:[], 'filename') ||
      message.try(:[], 'payload').try(:[], 'payload').try(:[], 'name')
  end

  attribute :error_code do |gwm|
    message = gwm.error_payload
    error = message.try(:[], 'payload').try(:[], 'payload')
    next '' unless error.present?

    error['code']
  end

  attribute :error_message do |gwm|
    message = gwm.error_payload
    error = message.try(:[], 'payload').try(:[], 'payload')
    next '' unless error.present? && error['code'] == 1002

    case error['code']
    when 1002
      I18n.t('errors.gupshup_errors.not_existing_number')
    end
  end

  attribute :sender_full_name do |gwm|
    next if gwm.direction == 'inbound' || gwm.retailer_user_id.blank?

    full_name = "#{gwm.sender_first_name} #{gwm.sender_last_name}".strip
    full_name.presence || gwm.sender_email
  end

  attribute :will_retry do |gwm|
    gwm.direction == 'outbound' && gwm.mexican_error? && gwm.able_for_retry?
  end
end
