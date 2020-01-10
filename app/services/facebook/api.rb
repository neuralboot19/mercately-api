module Facebook
  class Api
    def initialize(facebook_retailer, retailer_user)
      @facebook_retailer = facebook_retailer
      @retailer_user = retailer_user
    end

    def self.validate_granted_permissions(access_token)
      params = {
        access_token: access_token
      }
      url = "https://graph.facebook.com/me/permissions?#{params.to_query}"
      conn = Connection.prepare_connection(url)
      response = Connection.get_request(conn)
      return false if response['error']

      permissions = response['data'].map { |d| d['status'] == 'granted' }
      !permissions.include?(false)
    end

    # Make sure call this method with a long live token on DB
    def update_retailer_access_token
      url = pages_url
      conn = Connection.prepare_connection(url)
      response = Connection.get_request(conn)
      save_page_access_token(response) if response
    end

    def save_page_access_token(response)
      response_data = response['data'].select { |r| r.key?('access_token') }
      page_data = response_data[0]
      @facebook_retailer.update(access_token: page_data['access_token'], uid: page_data['id'])
    end

    def long_live_user_access_token
      url = long_live_user_access_token_url
      conn = Connection.prepare_connection(url)
      Connection.get_request(conn)
    end

    def subscribe_page_to_webhooks
      url = webhooks_susbcription_url
      conn = Connection.prepare_connection(url)
      response = Connection.post_request(conn, prepare_webhook_subscription)
      JSON.parse(response.body)
    end

    private

      def pages_url
        params = {
          access_token: @retailer_user.facebook_access_token
        }
        "https://graph.facebook.com/#{@retailer_user.uid}/accounts?#{params.to_query}"
      end

      def long_live_user_access_token_url
        params = {
          grant_type: 'fb_exchange_token',
          client_id: ENV['FACEBOOK_APP_ID'],
          client_secret: ENV['FACEBOOK_APP_SECRET'],
          fb_exchange_token: @retailer_user.facebook_access_token
        }
        "https://graph.facebook.com/v5.0/oauth/access_token?#{params.to_query}"
      end

      def prepare_webhook_subscription
        {
          subscribed_fields: 'messages,message_deliveries,message_reads'
        }.to_json
      end

      def webhooks_susbcription_url
        params = {
          access_token: @facebook_retailer.access_token
        }
        "https://graph.facebook.com/v5.0/#{@facebook_retailer.uid}/subscribed_apps?#{params.to_query}"
      end

      def permissions_url(access_token)
        params = {
          access_token: access_token
        }
        "https://graph.facebook.com/me/permissions?#{params.to_query}"
      end
  end
end
