module Api
  class MobileController < Retailers::Api::V1::ApiController
    def check_access
      disable_access_by_authorization
    end

    private

      def disable_access_by_authorization
        validate_headers
        validate_token

        return record_not_found unless @mobile_token
        return render_unauthorized unless @mobile_token.token == request.get_header('HTTP_TOKEN')
        return response_generate_token unless @mobile_token.expiration > Time.now

        @current_retailer_user = @mobile_token.retailer_user
        @current_retailer = @current_retailer_user.retailer
      rescue StandardError => e
        Rails.logger.error e
      end

      def response_generate_token
        token = @mobile_token.generate!
        @mobile_token.save!

        response.headers['Authorization'] = token
        response.headers['Device'] = @mobile_token.device
        set_response(
          401,
          'Token Expirado, se ha generado uno nuevo',
          {
            token: token
          }.to_json
        ) and return
      end

      def validate_headers
        return render_forbidden unless request.get_header('HTTP_EMAIL').present?
        return render_forbidden unless request.get_header('HTTP_DEVICE').present?
        render_unauthorized unless request.get_header('HTTP_TOKEN').present?
      end

      def validate_token
        @mobile_token = MobileToken.eager_load(:retailer_user)
          .find_by(
            'retailer_users.email = ? AND mobile_tokens.device = ?',
            request.get_header('HTTP_EMAIL'),
            request.get_header('HTTP_DEVICE')
          )
      end
  end
end
