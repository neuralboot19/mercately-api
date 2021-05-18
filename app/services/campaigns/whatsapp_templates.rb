module Campaigns
  class WhatsappTemplates
    def execute
      campaigns = Campaign.pending.where(send_at: 2.minutes.ago..1.minute.from_now)
      return unless campaigns.exists?

      campaign_ids = campaigns.ids
      campaigns.update_all status: :processing
      Campaign.includes(contact_group: :customers).where(id: campaign_ids).each do |c|
        if c.retailer.ws_balance < c.estimated_cost
          c.update(reason: :insufficient_balance, status: :failed)
          next
        end

        c.contact_group.customers.find_each do |cus|
          send_campaign(c, cus)
        end

        failed = if c.retailer.karix_integrated?
                   c.karix_whatsapp_messages.count == c.karix_whatsapp_messages.where(status: 'failed').count
                 else
                   c.gupshup_whatsapp_messages.count == c.gupshup_whatsapp_messages.error.count
                 end

        if failed
          c.update(reason: :service_down, status: :failed)
          c.failed!
        else
          c.sent!
        end
      end
    end

    private

      def send_campaign(campaign, customer)
        template = campaign.whatsapp_template
        # Se chequea si la campaña tiene asociado un archivo.
        has_file = campaign.file.attached?

        params = {
          gupshup_template_id: template.gupshup_template_id,
          template_params: campaign.customer_content_params(customer),
          type: has_file ? 'file' : 'template'
        }

        # Se arma la plantilla con los parametros de los customers en la campaña
        # Eliminando caracteres no deseados.
        aux_message = campaign.customer_details_template(customer).gsub(/(\r)/, '')

        # Se insertan los datos restantes a los parametros para el envio, dependiendo si la plantilla
        # es de texto o archivo.
        if has_file
          params[:caption] = aux_message
          params[:url] = campaign.file_url
          params[:file_name] = campaign.file.filename.to_s
          params[:template] = 'true'
        else
          params[:message] = aux_message
        end

        if campaign.retailer.karix_integrated?
          send_karix_notification(campaign, params, customer)
        else
          send_gupshup_notification(campaign, params, customer)
        end
      end

      def send_gupshup_notification(campaign, params, customer)
        gws = Whatsapp::Gupshup::V1::Outbound::Msg.new(campaign.retailer, customer)
        response = gws.send_message(type: params[:type], params: params)

        # Guardamos el id del mensaje en la campaña para poder rastrear luego.
        message = response[:message]
        if message.class == GupshupWhatsappMessage
          message.campaign_id = campaign.id
          message.save
        end
      rescue => e
        Raven.capture_exception(e)
      end

      def send_karix_notification(campaign, params, customer)
        karix_helper = KarixNotificationHelper
        retailer = campaign.retailer
        response = karix_helper.ws_message_service.send_message(retailer, customer, params, 'text')

        message = retailer.karix_whatsapp_messages.find_or_initialize_by(uid: response['objects'][0]['uid'])
        message = karix_helper.ws_message_service.assign_message(message, retailer, response['objects'][0])
        message.campaign_id = campaign.id
        message.save
      end
  end
end
