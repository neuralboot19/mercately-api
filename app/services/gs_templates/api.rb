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

      if response&.[]('status') != 'success'
        notify_error_to_slack(gs_template, url, headers, {}, response)
        return
      end

      data = if gs_template.ws_template_id
               response['templates'].select { |tpl| tpl['id'] == gs_template.ws_template_id }.first
             else
               response['templates'].select { |tpl| tpl['elementName'] == gs_template.label }.first
             end

      return unless data

      create_whatsapp_template(retailer, data)
      gs_template.status = set_response_status(data)
      gs_template.save
    rescue => e
      notify_error_to_slack(gs_template, url, headers, {}, e)
    end

    def submit_gs_template(gs_template)
      retailer = gs_template.retailer
      retailer.update_gs_info if retailer.gupshup_app_id.blank? || retailer.gupshup_app_token.blank?

      if gs_template.file&.present?
        url = upload_media_url(retailer.gupshup_app_id)

        headers = { 'Authorization': retailer.gupshup_app_token }

        body = {
          file: Faraday::FilePart.new(gs_template.file.tempfile.path, gs_template.file.content_type),
          file_type: gs_template.file.content_type
        }

        conn = Connection.prepare_connection(url, :multipart)
        response = Connection.post_form_request(conn, body, headers)
        resp_upload_media_json = JSON.parse(response.body)

        if resp_upload_media_json.blank? || resp_upload_media_json['status'] == 'error'
          gs_template.send_slack_notify(resp_upload_media_json['message'])
          return
        end
      end

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

      if gs_template.file&.present? && resp_upload_media_json['status'] == 'success'
          body[:exampleMedia] = resp_upload_media_json['handleId']['message']
          body[:enableSample] = true
      end

      conn = Connection.prepare_connection(url)
      response = Connection.post_form_request(conn, body, headers)
      resp_json = JSON.parse(response.body)

      if resp_json&.[]('status') != 'success'
        notify_error_to_slack(gs_template, url, headers, body, resp_json)
        return
      end

      gs_template.status = set_response_status(resp_json['template'])
      gs_template.ws_template_id = resp_json['template']['id']
      gs_template.save
    rescue => e
      notify_error_to_slack(gs_template, url, headers, body, e)
      Raven.capture_exception(e)
    end

    private

      def upload_media_url(gs_app_id)
        "https://partner.gupshup.io/partner/app/#{gs_app_id}/upload/media"
      end

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

      def notify_error_to_slack(gs_template, url, headers, body, resp)
        return unless ENV['ENVIRONMENT'] == 'production'

        slack_client = Slack::Notifier.new ENV['SLACK_GS_TEMPLATES'], channel: '#gs-templates'
        retailer = gs_template.retailer

        slack_client.ping([
          "Template: (#{gs_template.id}) #{gs_template.label}",
          "Retailer: (#{retailer.id}) #{retailer.name}",
          "URL: #{url}",
          "Headers: #{headers.to_json}",
          "Body: #{body.to_json}",
          "Response: #{resp.to_json}"
        ].join("\n"))
      rescue
        Rails.logger.error('Slack disabled')
      end
  end
end
