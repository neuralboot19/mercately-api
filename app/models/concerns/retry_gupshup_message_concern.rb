module RetryGupshupMessageConcern
  extend ActiveSupport::Concern

  included do
    after_save :retry_message, if: :saved_change_to_status?
  end

  def mexican_error?
    return false unless status == 'error'

    country_id = customer.country_id
    if country_id.blank?
      parse_destination = Phonelib.parse(destination)
      country_id = parse_destination&.country
    end

    return false unless country_id == 'MX'
    return false unless error_payload.try(:[], 'payload').try(:[], 'payload').present?

    true
  end

  def able_for_retry?
    error = error_payload.try(:[], 'payload').try(:[], 'payload')

    error.present? && error['code'].in?([1005, 1006, 1007, 1008]) && customer.number_to_use.present? &&
      customer.phone != customer.number_to_use && destination != customer.phone_number_to_use(false)
  end

  private

    def retry_message
      return unless direction == 'outbound' && mexican_error? && able_for_retry?

      msg_service = Whatsapp::Gupshup::V1::Outbound::Msg.new(retailer, customer)
      params = build_retry_params
      msg_service.send_message(type: params[:main_type], params: params, retailer_user: retailer_user, retry: true)
    end

    def build_retry_params
      case type
      when 'text'
        {
          message: message_payload['text'],
          type: message_payload['type'],
          gupshup_template_id: message_payload['id'],
          template_params: message_payload['params'],
          main_type: message_payload['isHSM'] == 'true' ? 'template' : 'text'
        }
      when 'file'
        {
          url: message_payload['url'],
          type: message_payload['type'],
          file_name: message_payload['filename'],
          caption: message_payload['caption'],
          template: message_payload['isHSM'],
          content_type: 'application/pdf',
          main_type: 'file'
        }
      when 'image'
        {
          url: message_payload['originalUrl'],
          type: message_payload['type'],
          caption: message_payload['caption'],
          content_type: 'image/',
          main_type: 'file'
        }
      when 'audio', 'voice'
        {
          url: message_payload['url'],
          type: message_payload['type'],
          main_type: 'file'
        }
      when 'video'
        {
          url: message_payload['url'],
          type: message_payload['type'],
          caption: message_payload['caption'],
          content_type: 'video/',
          main_type: 'file'
        }
      when 'location'
        {
          type: message_payload['type'],
          longitude: message_payload['longitude'],
          latitude: message_payload['latitude'],
          main_type: 'location'
        }
      end
    end
end
