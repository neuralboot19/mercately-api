module Reminders
  class WhatsappTemplates
    def execute
      # Busca todos los recordatorios cuyo status sea scheduled, y que esten en el rango de
      # la hora actual y un minuto luego.
      reminders = Reminder.scheduled.where(send_at_timezone: 2.minutes.ago..1.minute.from_now)
      return unless reminders.exists?

      reminder_ids = reminders.ids
      reminders.update_all status: :processing
      Reminder.where(id: reminder_ids).each do |r|
        unless r.retailer.positive_balance?(r.customer)
          r.update_column(:status, :failed)
          next
        end

        send(r)
      end
    end

    private
      # Se encarga de armar la data necesaria para enviar una plantilla sea por Karix o GS.
      def send(reminder)
        template = reminder.whatsapp_template
        # Se chequea si el recordatorio tiene asociado un archivo.
        has_file = reminder.file.attached?
        resource_type = has_file ? 'file' : 'template'

        params = {
          gupshup_template_id: template.gupshup_template_id,
          template_params: reminder.content_params,
          type: has_file ? get_content_type(reminder) : 'text',
          template: 'true'
        }

        # Se arma la plantilla con los parametros ingresados en la creacion del recordatorio
        # Eliminando caracteres no deseados.
        aux_message = template.template_text(params).gsub('\\*', '*')
        aux_message = aux_message.gsub(/(\r)/, '')

        # Se insertan los datos restantes a los parametros para el envip, dependiendo si la plantilla
        # es de texto o archivo.
        if has_file
          params[:caption] = aux_message
          params[:url] = reminder.file_url
          params[:file_name] = reminder.file.filename.to_s
        else
          params[:message] = aux_message
        end

        if reminder.retailer.karix_integrated?
          send_karix_notification(reminder, params)
        else
          send_gupshup_notification(reminder, params, resource_type)
        end
      end

      def send_gupshup_notification(reminder, params, resource_type)
        gws = Whatsapp::Gupshup::V1::Outbound::Msg.new(reminder.retailer, reminder.customer)
        response = gws.send_message(type: resource_type, params: params)

        # Si la respuesta del envio es exitosa y devuelve el mensaje, seteamos el status
        # del recordatorio en sent. Caso contrario seteamos en failed.
        status = response[:message]&.class&.name == 'GupshupWhatsappMessage' ? 'sent' : 'failed'
        # Guardamos el id del mensaje en el recordatorio para poder rastrear luego.
        reminder.update(status: status, gupshup_whatsapp_message_id: status == 'sent' ? response[:message].id : nil)
      end

      def send_karix_notification(reminder, params)
        karix_helper = KarixNotificationHelper
        retailer = reminder.retailer
        response = karix_helper.ws_message_service.send_message(retailer, reminder.customer, params, 'text')

        # Si el envio es exitoso seteamos como sent el recordatorio. Caso contrario seteamos failed.
        if response['error'].present?
          reminder.update(status: 'failed')
        else
          message = retailer.karix_whatsapp_messages.find_or_initialize_by(uid: response['objects'][0]['uid'])
          message = karix_helper.ws_message_service.assign_message(message, retailer, response['objects'][0])
          message.save

          status = 'sent'
          status = 'failed' if message.status == 'failed'
          # Guardamos el id del mensaje en el recordatorio para poder rastrear luego.
          reminder.update(status: status, karix_whatsapp_message_id: message.id)
        end
      end

      def get_content_type(reminder)
        content_type = reminder.file.content_type
        return 'image' if content_type.include?('image')
        return 'video' if content_type.include?('video')

        'document'
      end
  end
end
