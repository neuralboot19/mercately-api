# frozen_string_literal: true

module Api::V1::Mobile
  class RegistrationsController < Api::MobileController
    skip_before_action :disable_access_by_authorization, only: :create

    def create
      @user = RetailerUser.new(retailer_user_params)

      if @user.save
        @user.generate_api_token!

        response.headers['Authorization'] = @user.api_session_token
        response.headers['Device'] = @user.api_session_device
        serialized = Api::V1::RetailerUserSerializer.new(
          @user,
          include: [
            :retailer
          ]
        ).serialized_json
        render json: serialized, status: 200
      else
        render json: { error: @user.errors.full_messages }, status: 400
      end
    end

    private

      def retailer_user_params
        params.require(:retailer_user).permit(
          :email,
          :first_name,
          :last_name,
          :password,
          :password_confirmation,
          :agree_terms,
          retailer_attributes: [:name, :retailer_number]
        )
      end
  end
end
