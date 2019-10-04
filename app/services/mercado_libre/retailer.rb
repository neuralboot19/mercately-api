module MercadoLibre
  class Retailer
    def initialize(retailer)
      @retailer = retailer
      @meli_retailer = @retailer.meli_retailer
    end

    def save_retailer(identification, address, phone)
      @retailer.update(
        id_number: identification['number'], id_type: identification['type'].downcase,
        address: address['address'], city: address['city'], state: address['state'], zip_code: address['zip_code'],
        phone_number: phone['number'], phone_verified: phone['verified']
      )
    end

    def update_retailer_info
      url = prepare_retailer_update_url
      conn = Connection.prepare_connection(url)
      response = Connection.get_request(conn)
      return @meli_retailer if response['error'].present? || response['message']&.[]('error').present?

      save_retailer(response['identification'], response['address'], response['phone'])
      update_meli_retailer(
        response, response['seller_reputation'], response['seller_experience'],
        response['seller_reputation']['transactions']
      )
    end

    def update_meli_retailer(info, seller_reputation, seller_experience, trans)
      @meli_retailer.update(
        nickname: info['nickname'], email: info['email'], points: info['points'], link: info['permalink'],
        seller_experience: seller_experience, seller_reputation_level_id: seller_reputation['level_id'],
        transactions_canceled: trans['canceled'], transactions_completed: trans['completed'],
        ratings_negative: trans['ratings']['negative'], ratings_neutral: trans['ratings']['neutral'],
        ratings_positive: trans['ratings']['positive'], ratings_total: trans['total'], has_meli_info: true,
        meli_info_updated_at: DateTime.current
      )
    end

    private

      def prepare_retailer_update_url
        params = {
          access_token: @meli_retailer.access_token
        }
        "https://api.mercadolibre.com/users/#{@meli_retailer.meli_user_id}?#{params.to_query}"
      end
  end
end
