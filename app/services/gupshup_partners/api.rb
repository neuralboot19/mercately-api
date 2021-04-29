module GupshupPartners
  class Api
    def get_token
      # La actualizacion del token se debe hacer solo desde produccion, ya que si lo cambiamos
      # en local, inhabilitamos el token guardado en la DB de alla.
      return unless ENV['ENVIRONMENT'] == 'production'

      url = gs_token_url
      body = {
        email: ENV['GUPSHUP_EMAIL_PARTNER'],
        password: ENV['GUPSHUP_PASS_PARTNER']
      }

      conn = Connection.prepare_connection(url)
      response = Connection.post_form_request(conn, body)
      resp_json = JSON.parse(response.body)

      return unless (resp_json['id'].present? || resp_json['name'].present?) && resp_json['token'].present?

      gs_partner = GupshupPartner.find_by(partner_id: resp_json['id']).presence ||
        GupshupPartner.find_by(name: resp_json['name'])

      if gs_partner.present?
        gs_partner.update(token: resp_json['token'])
      else
        GupshupPartner.create(partner_id: resp_json['id'], name: resp_json['name'], token: resp_json['token'])
      end
    end

    def get_app_ids
      gs_partner = GupshupPartner.all.first
      return unless gs_partner.present?

      url = gs_app_ids_url
      headers = {
        token: gs_partner.token
      }

      conn = Connection.prepare_connection(url)
      response = Connection.get_request(conn, headers)

      return unless response['partnerAppsList'].present?

      response['partnerAppsList'].each do |app|
        retailer = Retailer.find_by(gupshup_src_name: app['name'])
        retailer&.update_column(:gupshup_app_id, app['id'])
      end
    end

    def get_app_tokens
      gs_partner = GupshupPartner.all.first
      return unless gs_partner.present?

      headers = {
        token: gs_partner.token
      }

      Retailer.where.not(gupshup_app_id: nil).find_each do |retailer|
        url = gs_app_tokens_url(retailer.gupshup_app_id)
        conn = Connection.prepare_connection(url)
        response = Connection.get_request(conn, headers)
        next unless response['token'].present?

        retailer.update_column(:gupshup_app_token, response['token']['token'])
      end
    end

    def set_app_id(app_name)
      gs_partner = GupshupPartner.all.first
      return unless gs_partner.present?

      gs_partner.update_token

      url = gs_app_ids_url
      headers = {
        token: gs_partner.token
      }

      conn = Connection.prepare_connection(url)
      response = Connection.get_request(conn, headers)

      return unless response['partnerAppsList'].present?

      app = response['partnerAppsList'].select { |app| app['name'] == app_name }.first
      app.present? ? app['id'] : nil
    end

    def set_app_token(gs_app_id)
      gs_partner = GupshupPartner.all.first
      return unless gs_partner.present?

      gs_partner.update_token

      headers = {
        token: gs_partner.token
      }

      url = gs_app_tokens_url(gs_app_id)
      conn = Connection.prepare_connection(url)
      response = Connection.get_request(conn, headers)
      return unless response['token'].present?

      response['token']['token']
    end

    def get_updated_token
      # La actualizacion del token se debe hacer solo desde produccion, ya que si lo cambiamos
      # en local, inhabilitamos el token guardado en la DB de alla.
      return unless ENV['ENVIRONMENT'] == 'production'

      url = gs_token_url
      body = {
        email: ENV['GUPSHUP_EMAIL_PARTNER'],
        password: ENV['GUPSHUP_PASS_PARTNER']
      }

      conn = Connection.prepare_connection(url)
      response = Connection.post_form_request(conn, body)
      resp_json = JSON.parse(response.body)

      resp_json['token']
    end

    private

      def gs_token_url
        'https://partner.gupshup.io/partner/account/login'
      end

      def gs_app_ids_url
        'https://partner.gupshup.io/partner/account/api/partnerApps'
      end

      def gs_app_tokens_url(gs_app_id)
        "https://partner.gupshup.io/partner/app/#{gs_app_id}/token"
      end
  end
end
