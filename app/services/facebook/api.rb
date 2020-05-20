module Facebook
  class Api
    def initialize(facebook_retailer, retailer_user)
      @facebook_retailer = facebook_retailer
      @retailer_user = retailer_user
    end

    def self.validate_granted_permissions(access_token, connection_type)
      params = {
        access_token: access_token
      }
      url = "https://graph.facebook.com/me/permissions?#{params.to_query}"
      conn = Connection.prepare_connection(url)
      response = Connection.get_request(conn)
      return { granted_permissions: false } if response['error']

      if connection_type == 'messenger'
        messenger_permissions = ['email', 'pages_messaging', 'manage_pages', 'pages_show_list']
        granted_permissions = response['data'].any? { |d| messenger_permissions.include?(d['permission']) &&
          d['status'] == 'declined' }
      elsif connection_type == 'catalog'
        catalog_permissions = ['business_management', 'catalog_management']
        granted_permissions = response['data'].any? { |d| catalog_permissions.include?(d['permission']) &&
          d['status'] == 'declined' }
      end

      {
        permissions: response['data'],
        granted_permissions: !granted_permissions
      }
    end

    # Make sure call this method with a long live token on DB
    def update_retailer_access_token
      url = pages_url
      conn = Connection.prepare_connection(url)
      response = Connection.get_request(conn)
      save_page_access_token(response) if response
      subscribe_page_to_webhooks
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

    def businesses
      url = businesses_url
      conn = Connection.prepare_connection(url)
      Connection.get_request(conn)
    end

    def business_product_catalogs(business_id)
      url = business_product_catalogs_url(business_id)
      conn = Connection.prepare_connection(url)
      Connection.get_request(conn)
    end

    def create_product_url
      params = {
        access_token: @retailer_user.facebook_access_token
      }
      "https://graph.facebook.com/v5.0/#{@retailer_user.retailer.facebook_catalog.uid}/products?" \
        "#{params.to_query}"
    end

    def update_product_url(product)
      params = {
        access_token: @retailer_user.facebook_access_token
      }
      "https://graph.facebook.com/v5.0/#{product.facebook_product_id}?#{params.to_query}"
    end

    def delete_product_url(product)
      params = {
        access_token: @retailer_user.facebook_access_token
      }
      "https://graph.facebook.com/v5.0/#{product.facebook_product_id}?#{params.to_query}"
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

      def businesses_url
        params = {
          access_token: @retailer_user.facebook_access_token
        }
        "https://graph.facebook.com/#{@retailer_user.uid}/businesses?#{params.to_query}"
      end

      def business_product_catalogs_url(business_id)
        params = {
          access_token: @retailer_user.facebook_access_token
        }
        "https://graph.facebook.com/v5.0/#{business_id}/owned_product_catalogs?#{params.to_query}"
      end

      def subscribe_page_to_webhooks
        url = webhooks_susbcription_url
        conn = Connection.prepare_connection(url)
        response = Connection.post_request(conn, prepare_webhook_subscription)
        JSON.parse(response.body)
      end
  end
end
