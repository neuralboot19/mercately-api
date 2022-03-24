namespace :retailers do
  task :gupshup_import_templates_by_app_name, [:app_name] => :environment do |t, args|
    retailer = Retailer.find_by_gupshup_src_name(args[:app_name])
    return if retailer.blank?

    url = "https://partner.gupshup.io/partner/app/#{retailer.gupshup_app_id}/templates"
    headers = {
      'Connection': 'keep-alive',
      'token': retailer.gupshup_app_token
    }

    conn = Connection.prepare_connection(url)
    response = Connection.get_request(conn, headers)

    if response["templates"].present?
      api_service = GsTemplates::Api.new
      gs_templates = retailer.gs_templates

      response['templates'].each do |template|
        template_saved = gs_templates.find do |gs_template|
          gs_template.ws_template_id == template['id'] || gs_template.label == template['elementName']
        end

        next unless template_saved.blank?
        next if template['status'] != 'APPROVED'

        api_service.create_only_whatsapp_template(retailer, template)
      end
    end
  end
end