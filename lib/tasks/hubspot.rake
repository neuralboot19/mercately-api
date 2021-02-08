namespace :hubspot do
  task refresh_token: :environment do
    Retailer.where(hs_expires_in: 7.day.ago..1.hour.from_now).find_each do |r|
      token = HubspotService::Api.new(r.hs_access_token).refresh_token(r.hs_refresh_token)
      r.update(
        hs_expires_in: token['expires_in'].seconds.from_now,
        hs_access_token: token['access_token'],
        hs_refresh_token: token['refresh_token']
      )
      sleep 0.1
    end
  end
end
