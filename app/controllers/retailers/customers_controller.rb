class Retailers::CustomersController < RetailersController
  before_action :set_customer, only: [:show, :edit, :update, :destroy]

  # GET /products
  def index
    @customers = current_retailer.customers.page(params[:page])
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
