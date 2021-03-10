namespace :facebook_retailers do
  task update_webhooks: :environment do
    FacebookRetailer.all.where.not(uid: nil, access_token: nil).each do |fb|
      url = webhooks_susbcription_url(fb)
      conn = Connection.prepare_connection(url)
      Connection.post_request(conn, prepare_webhook_subscription)
    end
  end
end

def prepare_webhook_subscription
  {
    subscribed_fields: 'messages,message_deliveries,message_reads,messaging_postbacks'
  }.to_json
end

def webhooks_susbcription_url(facebook_retailer)
  params = {
    access_token: facebook_retailer.access_token
  }

  "https://graph.facebook.com/v5.0/#{facebook_retailer.uid}/subscribed_apps?#{params.to_query}"
end
