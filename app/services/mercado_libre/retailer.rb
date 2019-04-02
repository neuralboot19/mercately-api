module MercadoLibre
  class Retailer
    def initialize(retailer)
      @retailer = retailer
      @meli_info = @retailer.meli_info
    end

    def update_retailer_info
      url = prepare_retailer_update_url
      conn = Connection.prepare_connection(url)
      response = Connection.get_request(conn)
      save_retailer(response['identification'], response['address'], response['phone'])
      update_meli_info(
        response, response['seller_reputation'], response['seller_experience'],
        response['seller_reputation']['transactions']
      )
    end

    def save_retailer(identification, address, phone)
      @retailer.update(
        id_number: identification['number'], id_type: identification['type'].downcase,
        address: address['address'], city: address['city'], state: address['state'], zip_code: address['zip_code'],
        phone_number: phone['number'], phone_verified: phone['verified']
      )
    end

    def update_meli_info(info, seller_reputation, seller_experience, trans)
      @meli_info.update(
        nickname: info['nickname'], email: info['email'], points: info['points'], link: info['permalink'],
        seller_experience: seller_experience, seller_reputation_level_id: seller_reputation['level_id'],
        transactions_canceled: trans['canceled'], transactions_completed: trans['completed'],
        ratings_negative: trans['ratings']['negative'], ratings_neutral: trans['ratings']['neutral'],
        ratings_positive: trans['ratings']['positive'], ratings_total: trans['total']
      )
    end

    private

      def prepare_retailer_update_url
        params = {
          access_token: @meli_info.access_token
        }
        "https://api.mercadolibre.com/users/#{@meli_info.meli_user_id}?#{params.to_query}"
      end
  end
end
