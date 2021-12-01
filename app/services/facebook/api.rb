module Facebook
  class Api
    def initialize(facebook_retailer, retailer_user, type = 'messenger')
      @facebook_retailer = facebook_retailer
      @retailer_user = retailer_user
      @type = type
      @klass = @type == 'instagram' ? InstagramMessage : FacebookMessage
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
        messenger_permissions = ['email', 'pages_messaging', 'pages_manage_metadata', 'pages_read_engagement',
                                 'pages_show_list']
        granted_permissions = response['data'].any? { |d| messenger_permissions.include?(d['permission']) &&
                                                      d['status'] == 'declined' }
      elsif connection_type == 'instagram'
        instagram_permissions = ['instagram_basic', 'instagram_manage_messages', 'pages_manage_metadata',
                               'pages_show_list']
        granted_permissions = response['data'].any? { |d| instagram_permissions.include?(d['permission']) &&
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

    def find_instagram_uid
      url = instagram_uid_url
      conn = Connection.prepare_connection(url)
      response = Connection.get_request(conn)
      return unless response

      raise 'NotIgAllowed' if response['instagram_business_account'].nil?

      @facebook_retailer.update!(instagram_uid: response['instagram_business_account']['id'])
    end

    def check_instagram_access
      url = instagram_conversations_url
      conn = Connection.prepare_connection(url)
      response = Connection.get_request(conn)
      response['error'].nil? ? true : false
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

    def send_bulk_files(customer, params)
      return unless params[:file_data]

      params[:file_data].each_with_index do |file, index|
        @index = index
        file_data = file.tempfile.path
        filename = File.basename(file.original_filename)
        save_message(customer, file_data, filename, params)
      end
    end

    def send_multiple_answers(customer, params)
      return unless params[:template_id]

      template = @facebook_retailer.retailer.templates.find_by_id(params[:template_id])
      return unless template.present?

      url = params[:url]
      type = params[:type]

      if params[:message].present?
        params[:url] = nil
        params[:type] = nil
        save_message(customer, nil, nil, params)
      end

      if url.present?
        params[:url] = url
        params[:type] = type
        params[:message] = nil
        identifier = params[:message_identifiers][0]
        params[:message_identifier] = identifier
        params[:message_identifiers].delete(identifier)

        save_message(customer, nil, nil, params)

        sleep 2
      end

      index = 0
      template.additional_fast_answers.order(id: :asc).each do |afa|
        if afa.answer.present?
          params[:url] = nil
          params[:type] = nil
          params[:message_identifier] = params[:message_identifiers][index]
          params[:message] = afa.answer
          index += 1
          save_message(customer, nil, nil, params)
        end

        if afa.file.attached?
          params[:message] = nil
          params[:message_identifier] = params[:message_identifiers][index]
          params[:url] = format_url(afa)
          params[:type] = afa.file_type
          index += 1
          save_message(customer, nil, nil, params)

          sleep 2
        end
      end
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

      def instagram_conversations_url
        params = {
          platform: 'instagram',
          access_token: @facebook_retailer.access_token
        }
        "https://graph.facebook.com/v11.0/#{@facebook_retailer.uid}/conversations?#{params.to_query}"
      end

      def instagram_uid_url
        params = {
          fields: 'instagram_business_account',
          access_token: @facebook_retailer.access_token
        }
        "https://graph.facebook.com/v11.0/#{@facebook_retailer.uid}?#{params.to_query}"
      end

      def prepare_webhook_subscription
        {
          subscribed_fields: 'messages,message_deliveries,message_reads,messaging_postbacks'
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

      def save_message(customer, file_data, filename, params)
        @klass.create(
          customer: customer,
          sender_uid: @retailer_user.uid,
          id_client: customer.psid,
          facebook_retailer: @facebook_retailer,
          file_data: file_data,
          sent_from_mercately: true,
          sent_by_retailer: true,
          filename: filename,
          retailer_user: @retailer_user,
          file_type: params[:type],
          file_url: params[:url],
          text: params[:message],
          message_identifier: @index ? params[:message_identifiers][@index] : params[:message_identifier]
        )
      end

      def format_url(afa)
        return afa.file_url if afa.file_type != 'image'

        formats = 'if_w_gt_1000/c_scale,w_1000/if_end/q_auto'
        afa.file_url.gsub('/image/upload', "/image/upload/#{formats}")
      end
  end
end
