module Api
  class ApiController < MobileController
    skip_before_action :disable_access_by_authorization
    before_action :authenticate_retailer_user!

    private

      def authenticate_retailer_user!
        check_access and return if headers_present
        super
      end

      def headers_present
        request.get_header('HTTP_EMAIL').present? ||
        request.get_header('HTTP_DEVICE').present? ||
        request.get_header('HTTP_TOKEN').present?
      end
  end
end
