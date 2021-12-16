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
      connection = Connection.prepare_connection('https://api.hubapi.com/integrations/v1/me')
      Connection.get_request(
        connection,
        authorization: "Bearer #{@access_token}"
      )
    end

    def contact_properties
      update_token
      connection = Connection.prepare_connection('https://api.hubapi.com/crm/v3/properties/contacts?archived=false')
      response = Connection.get_request(
        connection,
        authorization: "Bearer #{@access_token}"
      )
      response['results']
    end

    def contact(vid)
      update_token
      connection = Connection.prepare_connection("https://api.hubapi.com/crm/v3/objects/contacts/#{vid}?paginateAssociations=false&archived=false")
      Connection.get_request(
        connection,
        authorization: "Bearer #{@access_token}"
      )
    end

    def contact_create(params = {})
      update_token
      connection = Connection.prepare_connection('https://api.hubapi.com/crm/v3/objects/contacts')
      response = Connection.post_request(
        connection,
        {
          "properties": params
        }.to_json,
        authorization: "Bearer #{@access_token}"
      )
      JSON.parse(response.body)
    end

    def contact_update(vid, params = {})
      update_token
      connection = Connection.prepare_connection("https://api.hubapi.com/crm/v3/objects/contacts/#{vid}")
      response = Connection.patch_request(
        connection,
        {
          "properties": params
        }.to_json,
        authorization: "Bearer #{@access_token}"
      )
      JSON.parse(response.body)
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
      connection = Connection.prepare_connection('https://api.hubapi.com/crm/v3/objects/contacts/search')
      response = Connection.post_request(
        connection,
        {
          "filterGroups": [
            {
              "filters": filters
            }
          ]
        }.to_json,
        authorization: "Bearer #{@access_token}"
      )
      body = JSON.parse(response.body)
      body['results']&.first
    end
  end
end
