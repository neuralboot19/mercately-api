module Api::V1
  class SessionsController < Api::MobileController
    skip_before_action :disable_access_by_authorization, only: :create
    before_action :set_retailer, only: :create

    def create
      @user.mobile_tokens.destroy_all
      mobile_token = @user.mobile_tokens.build

      if mobile_token.save!
        token = mobile_token.generate!

        response.headers['Authorization'] = token
        response.headers['Device'] = mobile_token.device
        render json: serialize_retailer_user(@user), status: 200
      end
    end

    def delete
      @mobile_token.destroy
      set_response(200, 'Sesión cerrada correctamente')
    end

    private

      def create_params
        params.require(:retailer_user).permit(:email, :password)
      end

      def set_retailer
        @user = RetailerUser.find_by_email(create_params[:email])
        return record_not_found unless @user.present?
        return render_unauthorized unless @user.valid_password?(create_params[:password])

        @user
      end

      def serialize_retailer_user(retailer_user)
        Api::V1::RetailerUserSerializer.new(
          retailer_user,
          {
            include: [
              :retailer
            ]
          }
        ).serialized_json
      end
  end
end
