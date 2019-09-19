class Retailers::CustomersController < RetailersController
  before_action :set_customer, only: [:show, :edit, :update, :destroy, :customer_data]
  before_action :active_customers, only: :index

  # GET /products
  def index
  end

  # GET /products/1
  def show
  end

  # GET /products/new
  def new
    @customer = Customer.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products
  def create
    @customer = Customer.new(customer_params)
    @customer.retailer_id = @retailer.id

    if @customer.save
      redirect_to retailers_customers_path(@retailer), notice: 'Cliente creado con éxito.'
    else
      render :new
    end
  end

  # PATCH/PUT /products/1
  def update
    if @customer.update(customer_params)
      redirect_to retailers_customers_path(@retailer), notice: 'Cliente actualizado con éxito.'
    else
      render :edit
    end
  end

  # DELETE /products/1
  def destroy
    @customer.destroy
    redirect_to retailers_customers_path, notice: 'Customer was successfully destroyed.'
  end

  def customer_data
    render json: { customer: @customer }
  end

  def create_or_update_customer
    @customer = params[:id].present? ? Customer.find(params[:id]) : Customer.new

    @customer.update_attributes(first_name: params[:first_name], last_name: params[:last_name], email:
      params[:email], phone: params[:phone], retailer: @retailer)

    render json: { customer: @customer, errors: @customer.errors }
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params[:id])
    end

    def active_customers
      @customers = Retailer.active_customers(current_retailer).page(params[:page])
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
