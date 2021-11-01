class Api::V1::CustomFieldsMobileController < Api::MobileController
  before_action :set_retailer
  before_action :set_customer

  def bulk_update
    json_response = {}
    params[:custom_fields].each do |cf|
      # cf: Array containing [:key, value] Ex: [:my_integer_field, 7]
      identifier = cf.first
      value = cf.last
      field = CustomerRelatedField.find_by_identifier(identifier)
      if field.nil?
        json_response[:errors] ||= []
        json_response[:errors] << { cf => 404 }
        next
      end

      customer_field_data = @customer.customer_related_data.find_or_initialize_by(customer_related_field_id: field.id)
      customer_field_data.update(data: value)
    end

    render status: :ok, json: json_response
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = @user.retailer.customers.find(params[:customer_id])
    end

    def set_retailer
      @user = RetailerUser.find_by_email(request.headers['email'] || create_params[:email])
      return record_not_found unless @user

      @user
    end

    def create_params
      params.require(:retailer_user).permit(:email, :mobile_push_token)
    end
end
