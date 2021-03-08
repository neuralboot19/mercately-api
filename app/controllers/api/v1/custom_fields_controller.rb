class Api::V1::CustomFieldsController < Api::ApiController
  include CurrentRetailer
  before_action :set_customer, only: [:index, :update]

  def index
    render status: 200,
           json: {
             customer_fields: customer_fields,
             custom_fields: custom_fields
           }
  end

  def update
    field = CustomerRelatedField.find_by(id: params[:id])
    render_failure('Campo Personalizado no encontrado') and return unless field.present?
    customer_field_data = @customer.customer_related_data.find_or_initialize_by(customer_related_field_id: params[:id])
    data = params[:custom_field][customer_field_data.customer_related_field.identifier]
    customer_field_data.data = data

    if customer_field_data.save
      render status: 200,
             json: {
               customer_fields: customer_fields,
               custom_fields: custom_fields
             }
      return
    end

    render_failure(customer_field_data.errors.full_messages.join(', '))
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = current_retailer.customers.find(params[:customer_id])
    end

    def customer_fields
      data = []
      customer_related_data = @customer.customer_related_data.eager_load(:customer_related_field)

      customer_related_data.each do |crd|
        data.push(
          customer_id: @customer.id,
          customer_related_field_id: crd.customer_related_field_id,
          customer_related_field: {
            name: crd.customer_related_field.name,
            identifier: crd.customer_related_field.identifier,
            field_type: crd.customer_related_field.field_type,
            field_options: crd.customer_related_field.list_options
          },
          data: crd.data
        )
      end

      data
    end

    def custom_fields
      current_retailer
        .customer_related_fields
        .select(
          :id,
          :retailer_id,
          :name,
          :identifier,
          :field_type,
          :list_options
        ).as_json
    end

    def render_failure(errors)
      render status: 500, json: { message: errors }
    end
end
