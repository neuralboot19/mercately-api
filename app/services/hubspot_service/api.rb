module HubspotService
  class Api
    def initialize(access_token = nil)
      config = {
        client_id: ENV['HUBSPOT_CLIENT'],
        client_secret: ENV['HUBSPOT_CLIENT_SECRET'],
        redirect_uri: ENV['HUBSPOT_REDIRECT_URL']
      }
      if access_token
        @access_token = access_token
        config[:access_token] = @access_token
      end
      Hubspot.configure(config)
    end

    def reconfig
      Hubspot.configure(
        client_id: ENV['HUBSPOT_CLIENT'],
        client_secret: ENV['HUBSPOT_CLIENT_SECRET'],
        redirect_uri: ENV['HUBSPOT_REDIRECT_URL'],
        access_token: @access_token
      )
    end

    def refresh_token(refresh_token)
      reconfig
      token = Hubspot::OAuth.refresh(refresh_token)
      @access_token = token['access_token']
      token
    end

    def contact_properties
      connection = Connection.prepare_connection('https://api.hubapi.com/crm/v3/properties/contacts?archived=false')
      response = Connection.get_request(
        connection,
        authorization: "Bearer #{@access_token}"
      )
      response['results']
    end

    def contact(vid)
      connection = Connection.prepare_connection("https://api.hubapi.com/crm/v3/objects/contacts/#{vid}?paginateAssociations=false&archived=false")
      Connection.get_request(
        connection,
        authorization: "Bearer #{@access_token}"
      )
    end

    def contact_create(params = {})
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
