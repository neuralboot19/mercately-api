module Campaigns
  class SendCampaignJob < ApplicationJob
    queue_as :default

    def perform(campaign_id, customer_ids)
      c = Campaign.find(campaign_id)
      Customer.where(id: customer_ids).each do |cus|
        send_campaign(c, cus)
      end
    end

    private

      def send_campaign(campaign, customer)
        template = campaign.whatsapp_template
        params = {
          gupshup_template_id: template.gupshup_template_id,
          template_params: campaign.customer_content_params(customer),
          template: 'true'
        }

        # Se arma la plantilla con los parametros de los customers en la campaña
        # Eliminando caracteres no deseados.
        aux_message = campaign.customer_details_template(customer).gsub(/(\r)/, '')

        # Se insertan los datos restantes a los parametros para el envio, dependiendo si la plantilla
        # es de texto o archivo.
        if campaign.file.attached?
          resource_type = 'file'
          type = get_content_type(campaign)
          params[:caption] = aux_message
          params[:file_name] = campaign.file.filename.to_s
          aux_url = campaign.file_url

          if type == 'image'
            formats = 'if_w_gt_1000/c_scale,w_1000/if_end/q_auto'
            aux_url = aux_url.gsub('/image/upload', "/image/upload/#{formats}")
          end

          params[:url] = aux_url
        else
          type = 'text'
          resource_type = 'template'
          params[:message] = aux_message
        end

        params[:type] = type

        if campaign.retailer.karix_integrated?
          send_karix_notification(campaign, params, customer)
        else
          send_gupshup_notification(campaign, params, customer, resource_type)
        end
      end

      def send_gupshup_notification(campaign, params, customer, resource_type)
        gws = Whatsapp::Gupshup::V1::Outbound::Msg.new(campaign.retailer, customer)
        response = gws.send_message(type: resource_type, params: params)

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

      def get_content_type(campaign)
        content_type = campaign.file.content_type
        return 'image' if content_type.include?('image')
        return 'video' if content_type.include?('video')

        'document'
      end
  end
end
