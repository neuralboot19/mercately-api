module GsTemplates
  class Api
    def accept_gs_template(gs_template)
      retailer = gs_template.retailer
      retailer.update_gs_info if retailer.gupshup_app_id.blank? || retailer.gupshup_app_token.blank?

      url = templates_url(retailer.gupshup_app_id)
      headers = {
        'Connection': 'keep-alive',
        'token': retailer.gupshup_app_token
      }

      conn = Connection.prepare_connection(url)
      response = Connection.get_request(conn, headers)
      return unless response&.[]('status') == 'success'

      data = if gs_template.ws_template_id
               response['templates'].select { |tpl| tpl['id'] == gs_template.ws_template_id }.first
             else
               response['templates'].select { |tpl| tpl['elementName'] == gs_template.label }.first
             end

      return unless data

      create_whatsapp_template(retailer, data)
      gs_template.status = set_response_status(data)
      gs_template.save
    end

    def submit_gs_template(gs_template)
      retailer = gs_template.retailer
      retailer.update_gs_info if retailer.gupshup_app_id.blank? || retailer.gupshup_app_token.blank?

      url = templates_url(retailer.gupshup_app_id)
      headers = {
        'Connection': 'keep-alive',
        'token': retailer.gupshup_app_token
      }

      body = {
        elementName: gs_template.label,
        languageCode: GsTemplate::LANGUAGE_CODES[gs_template.language.to_sym],
        category: gs_template.category,
        templateType: gs_template.key.upcase,
        content: gs_template.text,
        example: gs_template.example,
        vertical: gs_template.label
      }

      conn = Connection.prepare_connection(url)
      response = Connection.post_form_request(conn, body, headers)
      resp_json = JSON.parse(response.body)
      return unless resp_json['template'].present?

      gs_template.status = set_response_status(resp_json['template'])
      gs_template.ws_template_id = resp_json['template']['id']
      gs_template.save
    end

    private

      def templates_url(gs_app_id)
        "https://partner.gupshup.io/partner/app/#{gs_app_id}/templates"
      end

      def create_whatsapp_template(retailer, gs_template_resp)
        return unless gs_template_resp['status'] == 'APPROVED'

        text = gs_template_resp['data'].gsub('*', '\*')
        text = text.gsub(/{{[1-9]+[0-9]*}}/, '*')
        text = text.gsub(/(\r)/, '')

        whatsapp_template = retailer.whatsapp_templates.find_or_create_by(gupshup_template_id: gs_template_resp['id'])
        whatsapp_template.text = text
        whatsapp_template.status = 'active'
        whatsapp_template.template_type = gs_template_resp['templateType'].downcase
        whatsapp_template.save
      end

      def set_response_status(data)
        case data['status']
        when 'PENDING'
          'submitted'
        when 'APPROVED'
          'accepted'
        when 'REJECTED'
          'rejected'
        end
      end
  end
end
