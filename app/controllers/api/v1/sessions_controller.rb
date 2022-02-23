module Api::V1
  class SessionsController < Api::MobileController
    skip_before_action :disable_access_by_authorization, only: :create
    before_action :valid_push_token, only: :create_mobile_push_token
    before_action :set_retailer, only: [:create, :create_mobile_push_token, :delete]
    before_action :valid_retailer_password, only: :create

    def create
      @user.generate_api_token!

      response.headers['Authorization'] = @user.api_session_token
      response.headers['Device'] = @user.api_session_device
      render json: serialize_retailer_user(@user), status: 200
    end

    def create_mobile_push_token
      @user.mobile_tokens.destroy_all
      mobile_token = @user.mobile_tokens.build(
        mobile_push_token: create_params[:mobile_push_token]
      )

      @user.update(mobile_type: create_params[:mobile_type]) if create_params[:mobile_type]

      if mobile_token.save!
        mobile_token.generate!
        render json: serialize_retailer_user(@user), status: 200
      end
    end

    def delete
      @user.destroy_api_token!
      @user.mobile_tokens.destroy_all
      set_response(200, 'Sesión cerrada correctamente')
    end

    private

      def create_params
        params.require(:retailer_user).permit(:email, :password, :mobile_push_token, :mobile_type)
      end

      def valid_retailer_password
        return render_unauthorized unless @user.valid_password?(create_params[:password])
      end

      def valid_push_token
        return render_unauthorized unless create_params[:mobile_push_token].present?
      end

      def set_retailer
        @user = RetailerUser.find_by_email(request.headers['email'] || create_params[:email])
        return record_not_found unless @user

        @user
      end

      def serialize_retailer_user(retailer_user)
        Api::V1::RetailerUserSerializer.new(
          retailer_user,
          include: [
            :retailer
          ]
        ).serialized_json
      end
  end
end
