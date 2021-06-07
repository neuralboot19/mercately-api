namespace :gupshup_partner do
  task get_token: :environment do
    gs_partner_service.get_token
  end

  task get_app_ids: :environment do
    gs_partner_service.get_app_ids
  end

  task get_app_tokens: :environment do
    gs_partner_service.get_app_tokens
  end
end

def gs_partner_service
  @gs_partner_service ||= GupshupPartners::Api.new
end
