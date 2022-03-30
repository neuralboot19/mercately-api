module HubspotService
  class Api
    def self.notify_broken_integration(retailer)
      SlackError.send_error("HS broken #{retailer.id}, Backtrace notify_broken_integration: #{caller[0]}")

      retailer.update(hs_access_token: nil)
      admins_supervisors = retailer.admins | retailer.supervisors
      admins_supervisors.each do |user|
        RetailerMailer.broken_hs_integration(user).deliver_now
      rescue StandardError => e
        SlackError.send_error(e)
      end
    end

    def initialize(access_token = nil)
      @access_token = access_token if access_token
    end

    def refresh_token(refresh_token)
      token = HTTParty.post(
        'https://api.hubapi.com/oauth/v1/token',
        body: {
          'grant_type': 'refresh_token',
          'client_id': ENV['HUBSPOT_CLIENT'],
          'client_secret': ENV['HUBSPOT_CLIENT_SECRET'],
          'redirect_uri': ENV['HUBSPOT_REDIRECT_URL'],
          'refresh_token': refresh_token
        },
        headers: { 'Content-Type' => 'application/x-www-form-urlencoded;charset=utf-8' }
      ).parsed_response

      @access_token = token['access_token']
      token
    rescue StandardError => e
      SlackError.send_error(e)
      retailer = Retailer.find_by(hs_access_token: @access_token)
      self.class.notify_broken_integration(retailer)
    end

    def update_token
      return false if @access_token.nil?

      retailer = Retailer.find_by(hs_access_token: @access_token)
      return if retailer.nil? || retailer.hs_expires_in > Time.now

      token = refresh_token(retailer.hs_refresh_token)
      @access_token = token['access_token']
      retailer.update(
        hs_expires_in: token['expires_in'].seconds.from_now,
        hs_access_token: token['access_token'],
        hs_refresh_token: token['refresh_token']
      )
    end

    def me
      update_token
      HTTParty.get(
        'https://api.hubapi.com/integrations/v1/me',
        headers: {
          'Content-Type' => 'application/json',
          authorization: "Bearer #{@access_token}"
        }
      ).parsed_response
    end

    def contact_properties
      update_token
      response = HTTParty.get(
        'https://api.hubapi.com/crm/v3/properties/contacts?archived=false',
        headers: {
          'Content-Type' => 'application/json',
          authorization: "Bearer #{@access_token}"
        }
      ).parsed_response
      response['results']
    end

    def contact(vid)
      update_token
      HTTParty.get(
        "https://api.hubapi.com/crm/v3/objects/contacts/#{vid}?paginateAssociations=false&archived=false",
        headers: {
          'Content-Type' => 'application/json',
          authorization: "Bearer #{@access_token}"
        }
      ).parsed_response
    end

    def contact_create(params = {})
      update_token
      HTTParty.post(
        'https://api.hubapi.com/crm/v3/objects/contacts',
        body: {
          properties: params
        }.to_json,
        headers: {
          'Content-Type' => 'application/json',
          authorization: "Bearer #{@access_token}"
        }
      ).parsed_response
    end

    def contact_update(vid, params = {})
      update_token
      HTTParty.patch(
        "https://api.hubapi.com/crm/v3/objects/contacts/#{vid}",
        body: {
          properties: params
        }.to_json,
        headers: {
          'Content-Type' => 'application/json',
          authorization: "Bearer #{@access_token}"
        }
      ).parsed_response
    end

    def search(params = {})
      update_token
      filters = []
      params.each do |k, v|
        filters << {
          'operator': 'CONTAINS_TOKEN',
          'propertyName': k,
          'value': v
        }
      end
      body = HTTParty.post(
        'https://api.hubapi.com/crm/v3/objects/contacts/search',
        body: {
          "filterGroups": [
            {
              "filters": filters
            }
          ]
        }.to_json,
        headers: {
          'Content-Type' => 'application/json',
          authorization: "Bearer #{@access_token}"
        }
      ).parsed_response
      body['results']&.first
    end

    def sync_conversations(email, messages, title)
      return if messages.empty?

      event_template = GlobalSetting.find_by_setting_key('event_template_id')
      return if event_template.blank?

      update_token
      response = HTTParty.post(
        'https://api.hubapi.com/crm/v3/timeline/events',
        body: {
          eventTemplateId: event_template.value,
          email: email,
          tokens: {
            event_title: title,
            amount_messages: messages.count
          },
          extraData: {
            messages: messages
          }
        }.to_json,
        headers: {
          'Content-Type' => 'application/json',
          authorization: "Bearer #{@access_token}"
        }
      ).parsed_response

      if response["status"].present? && response["status"] == 'error'
        SlackError.send_error(response["message"])
      end

      response
    rescue StandardError => e
      SlackError.send_error(e)
      Raven.capture_exception(e)
    end
  end
end
