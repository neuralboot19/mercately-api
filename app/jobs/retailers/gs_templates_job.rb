module Retailers
  class GsTemplatesJob < ApplicationJob
    queue_as :low

    def perform
      Retailer.joins(:gs_templates).where(gs_templates: {status: :submitted})
              .where.not(gupshup_phone_number: nil, gupshup_src_name: nil, gupshup_api_key: nil).find_each do |retailer|
        url = "https://partner.gupshup.io/partner/app/#{retailer.gupshup_app_id}/templates"
        headers = {
          'Connection': 'keep-alive',
          'token': retailer.gupshup_app_token
        }

        conn = Connection.prepare_connection(url)
        response = Connection.get_request(conn, headers)

        if response["templates"].present?
          retailer.gs_templates.submitted.each do |retailer_gs_template|

            gs_template = response['templates'].find do |gs_template|
              retailer_gs_template.ws_template_id == gs_template['id'] || retailer_gs_template.label == gs_template['elementName']
            end

            next if gs_template.blank?

            case gs_template['status']
            when 'REJECTED'
              retailer_gs_template.status = 'rejected'
              retailer_gs_template.save
            when 'APPROVED'
              retailer_gs_template.accept_template
            end
          end
        end
      end
    end
  end
end
