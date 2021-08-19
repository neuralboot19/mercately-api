module Api
  class MobileController < Retailers::Api::V1::ApiController
    def check_access
      disable_access_by_authorization
    end

    private

      def disable_access_by_authorization
        validate_headers
        find_retailer_user

        return record_not_found unless @current_retailer_user
        return render_unauthorized unless @current_retailer_user.api_session_token == request.get_header('HTTP_TOKEN')
        return response_generate_token unless @current_retailer_user.api_session_expiration > Time.now

        @current_retailer = @current_retailer_user.retailer
      rescue StandardError => e
        Rails.logger.error e
      end

      def response_generate_token
        token = @current_retailer_user.generate_api_token!

        response.headers['Authorization'] = token
        response.headers['Device'] = @current_retailer_user.api_session_device
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

      def find_retailer_user
        @current_retailer_user = RetailerUser.find_by(
          email: request.get_header('HTTP_EMAIL'),
          api_session_device: request.get_header('HTTP_DEVICE')
        )
      end
  end
end
