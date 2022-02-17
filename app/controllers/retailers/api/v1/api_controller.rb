module Retailers::Api::V1
  class ApiController < ActionController::Base
    include Responseable
    skip_before_action :verify_authenticity_token

    include ActionController::MimeResponds
    respond_to :json
    rescue_from Exception, with: :render_internal_server_error
    rescue_from ActiveRecord, with: :render_internal_server_error
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :active_model_errors

    before_action :disable_access_by_authorization

    private

      def not_found
        render(status: 404, json: { message: 'Not found' })
      end

      def disable_access_by_authorization
        slug = request.get_header 'HTTP_SLUG'
        @retailer = Retailer.find_by_slug(slug)
        record_not_found unless @retailer

        key = request.get_header 'HTTP_API_KEY'
        render_unauthorized unless @retailer.api_key == key && key.present?
      rescue StandardError => e
        Rails.logger.error e
        SlackError.send_error(e)
      end

    protected

      def current_retailer
        @retailer
      end

      def render_internal_server_error(exception)
        Rails.logger.error("API call EXCEPTION: #{exception.message}")
        SlackError.send_error(exception)
        Rails.logger.error(exception.backtrace.join("\n"))
        set_response(500, exception.message) and return
      end

      def render_unauthorized
        set_response(401, 'Unauthorized') and return
      end

      def render_forbidden
        set_response(403, 'Forbidden') and return
      end

      def record_not_found
        set_response(404, 'Resource not found') and return
      end

      def active_model_errors(exception)
        set_response(400, exception.record.errors.full_messages) and return
      end
    end
end
