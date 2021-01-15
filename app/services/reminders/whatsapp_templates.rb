module Reminders
  class WhatsappTemplates
    def execute
      current_time = Time.now
      Reminder.where(status: :scheduled, send_at_timezone: current_time..current_time + 1.minute).each do |r|
        send(r)
      end
    end

    private

      def send(reminder)
        template = reminder.whatsapp_template
        has_file = reminder.file.attached?

        params = {
          gupshup_template_id: template.gupshup_template_id,
          template_params: reminder.content_params,
          type: has_file ? 'file' : 'template'
        }

        aux_message = template.template_text(params).gsub('\\*', '*')
        aux_message = aux_message.gsub(/(\r)/, '')

        if has_file
          params[:caption] = aux_message
          params[:url] = reminder.file_url
          params[:file_name] = reminder.file.filename.to_s
          params[:template] = 'true'
        else
          params[:message] = aux_message
        end

        if reminder.retailer.karix_integrated?
          send_karix_notification(reminder, params)
        else
          send_gupshup_notification(reminder, params)
        end
      end

      def send_gupshup_notification(reminder, params)
        gws = Whatsapp::Gupshup::V1::Outbound::Msg.new(reminder.retailer, reminder.customer)
        response = gws.send_message(type: params[:type], params: params)

        status = response[:message]&.class&.name == 'GupshupWhatsappMessage' ? 'sent' : 'failed'
        reminder.update(status: status, gupshup_whatsapp_message_id: status == 'sent' ? response[:message].id : nil)
      end

      def send_karix_notification(reminder, params)
        karix_helper = KarixNotificationHelper
        retailer = reminder.retailer
        response = karix_helper.ws_message_service.send_message(retailer, reminder.customer, params, 'text')

        if response['error'].present?
          reminder.update(status: 'failed')
        else
          message = retailer.karix_whatsapp_messages.find_or_initialize_by(uid: response['objects'][0]['uid'])
          message = karix_helper.ws_message_service.assign_message(message, retailer, response['objects'][0])
          message.save

          status = 'sent'
          status = 'failed' if message.status == 'failed'
          reminder.update(status: status, karix_whatsapp_message_id: message.id)
        end
      end
  end
end
