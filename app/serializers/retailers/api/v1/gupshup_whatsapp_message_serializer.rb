module Retailers::Api::V1
  class GupshupWhatsappMessageSerializer < ActiveModel::Serializer
    attributes :id, :status, :direction, :channel, :message_type,
      :message_identifier, :created_time, :replied_message, :filename,
      :content_type, :content_text, :content_media_url, :content_media_caption,
      :content_media_type, :content_location_longitude, :content_location_latitude,
      :content_location_label, :content_location_address, :status, :account_uid,
      :contacts_information, :error_code, :error_message

    def id
      object.gupshup_message_id
    end

    def content_type
      message = object.message_payload
      type = message.try(:[], 'payload').try(:[], 'type') || message['type']
      type = message.try(:[], 'type') if type.blank?
      return 'text' if ['text', 'quick_reply'].include?(type)
      return 'media' if %[image audio video file sticker].include?(type)
      return 'location' if type == 'location'
      return 'contact' if type == 'contact'
    end

    def content_text
      message = object.message_payload
      type = message.try(:[], 'payload').try(:[], 'type') || message['type']
      return '' unless ['text', 'quick_reply'].include?(type)

      message['payload'].try(:[], 'payload').try(:[], 'text') || message['text']
    end

    def content_media_url
      message = object.message_payload
      type = message.try(:[], 'payload').try(:[], 'type') || message['type']
      return '' unless %[image audio video file sticker].include?(type)

      url = message.try(:[], 'originalUrl') ||
        message.try(:[], 'payload').try(:[], 'payload').try(:[],'url') ||
        message.try(:[], 'url') || ''

      url.gsub('http:', 'https:')
    end

    def content_media_caption
      message = object.message_payload
      type = message.try(:[], 'payload').try(:[], 'type') || message['type']
      return '' unless %[image audio video sticker].include?(type)

      if %[image audio video file sticker].include?(type)
        return message.try(:[], 'caption') ||
          message.try(:[], 'payload').try(:[], 'payload').try(:[],'caption')
      end

      ''
    end

    def content_media_type
      message = object.message_payload
      type = message.try(:[], 'payload').try(:[], 'type') || message['type']
      return '' if type == 'text'
      return 'document' if type == 'file'

      type
    end

    def content_location_longitude
      message = object.message_payload
      type = (object.direction == 'inbound' ? message.try(:[], 'payload').try(:[], 'type') : message.try(:[], 'type')) ||
        message['type']
      return '' unless type == 'location'

      object.direction == 'inbound' ? message['payload']['payload']['longitude'] : message['longitude']
    end

    def content_location_latitude
      message = object.message_payload
      type = (object.direction == 'inbound' ? message.try(:[], 'payload').try(:[], 'type') : message.try(:[], 'type')) ||
        message['type']
      return '' unless type == 'location'

      object.direction == 'inbound' ? message['payload']['payload']['latitude'] : message['latitude']
    end

    def content_location_label
      message = object.message_payload
      type = (object.direction == 'inbound' ? message.try(:[], 'payload').try(:[], 'type') : message.try(:[], 'type')) ||
        message['type']
      return '' unless type == 'location'

      message['name']
    end

    def content_location_address
      message = object.message_payload
      type = (object.direction == 'inbound' ? message.try(:[], 'payload').try(:[], 'type') : message.try(:[], 'type')) ||
        message['type']
      return '' unless type == 'location'

      message['address']
    end

    def status
      object.status.to_s
    end

    def account_uid
      object.gupshup_message_id
    end

    def uid
      object.gupshup_message_id
    end

    def message_type
      'conversation'
    end

    def created_time
      object.created_at
    end

    def contacts_information
      message = object.message_payload
      type = message.try(:[], 'payload').try(:[], 'type') || message['type']
      return [] unless type == 'contact'

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

    def replied_message
      message = object.message_payload
      id = message.try(:[], 'payload').try(:[], 'context').try(:[], 'id')
      gs_id = message.try(:[], 'payload').try(:[], 'context').try(:[], 'gsId')
      return unless id.present? || gs_id.present?

      customer = Customer.find_by(id: object.customer_id)
      return unless customer.present?

      replied = customer.gupshup_whatsapp_messages.find_by_whatsapp_message_id(id).presence ||
        customer.gupshup_whatsapp_messages.find_by_gupshup_message_id(gs_id)

      return unless replied.present?

      JSON.parse(
        GupshupWhatsappMessageSerializer.new(
          replied
        ).to_json
      )
    end

    def filename
      message = object.message_payload
      type = message.try(:[], 'payload').try(:[], 'type') || message['type']
      return '' unless type == 'file'

      return message.try(:[], 'filename') || message.try(:[], 'payload').try(:[], 'payload').try(:[], 'filename') ||
        message.try(:[], 'payload').try(:[], 'payload').try(:[], 'name')
    end

    def error_code
      message = object.error_payload
      error = message.try(:[], 'payload').try(:[], 'payload')
      return '' unless error.present?

      error['code']
    end

    def error_message
      message = object.error_payload
      error = message.try(:[], 'payload').try(:[], 'payload')
      return '' unless error.present? && error['code'] == 1002

      case error['code']
      when 1002
        I18n.t('errors.gupshup_errors.not_existing_number')
      end
    end
  end
end
