class Retailers::CustomersController < RetailersController
  before_action :set_customer, only: [:show, :edit, :update, :destroy, :customer_data]

  def index
    @q = if params[:q]&.[](:s).blank?
           current_retailer.customers.active.order(created_at: :desc).ransack(params[:q])
         else
           current_retailer.customers.active.ransack(params[:q])
         end

    @customers = @q.result.page(params[:page])
  end

  def show
  end

  def new
    @customer = Customer.new
  end

  def edit
  end

  def create
    @customer = Customer.new(customer_params)
    @customer.retailer_id = @retailer.id

    if @customer.save
      redirect_to retailers_customers_path(@retailer), notice: 'Cliente creado con éxito.'
    else
      render :new
    end
  end

  def update
    if @customer.update(customer_params)
      redirect_to retailers_customers_path(@retailer), notice: 'Cliente actualizado con éxito.'
    else
      render :edit
    end
  end

  def customer_data
    render json: { customer: @customer }
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def customer_params
      params.require(:customer).permit(
        :first_name,
        :last_name,
        :email,
        :phone,
        :id_type,
        :id_number,
        :address,
        :city,
        :state,
        :zip_code,
        :country_id
      )
    end
end
