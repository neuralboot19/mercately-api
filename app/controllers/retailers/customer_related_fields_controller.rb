class Retailers::CustomerRelatedFieldsController < RetailersController
  before_action :check_ownership, only: [:show, :edit, :update, :destroy]
  before_action :set_customer_related_field, only: [:show, :edit, :update, :destroy]

  def index
    @customer_related_fields = current_retailer.customer_related_fields.page(params[:page])
  end

  def show
  end

  def new
    @customer_related_field = CustomerRelatedField.new
  end

  def edit
  end

  def create
    @customer_related_field = current_retailer.customer_related_fields.new(customer_related_field_params)

    if @customer_related_field.save
      redirect_to retailers_customer_related_field_path(current_retailer, @customer_related_field), notice:
        'Campo creado con éxito.'
    else
      render :new
    end
  end

  def update
    if @customer_related_field.update(customer_related_field_params)
      redirect_to retailers_customer_related_field_path(current_retailer, @customer_related_field), notice:
        'Campo actualizado con éxito.'
    else
      render :edit
    end
  end

  def destroy
    if @customer_related_field.destroy
      redirect_to retailers_customer_related_fields_path(current_retailer), notice:
        'Campo eliminado con éxito.'
    else
      redirect_to retailers_customer_related_fields_path(current_retailer), notice:
        @customer_related_field.errors.full_messages.join(', ')
    end
  end

  private

    def customer_related_field_params
      params.require(:customer_related_field).permit(
        :name,
        :field_type,
        list_options: []
      )
    end

    def check_ownership
      customer_related_field = CustomerRelatedField.find_by(web_id: params[:id])
      redirect_to retailers_dashboard_path(current_retailer) unless customer_related_field &&
        current_retailer.customer_related_fields.exists?(customer_related_field.id)
    end

    def set_customer_related_field
      @customer_related_field = CustomerRelatedField.find_by(web_id: params[:id])
    end
end
