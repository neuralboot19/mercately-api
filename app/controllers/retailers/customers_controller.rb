# frozen_string_literal: true

class Retailers::CustomersController < RetailersController
  before_action :check_ownership, only: [:show, :edit, :update, :destroy]
  before_action :set_customer, only: [:show, :edit, :update, :destroy]

  def index
    cus = current_retailer.customers
      .select("customers.*,
                     (COUNT(orders)) as total_orders,
                     (case when orders.status = 0 then COUNT(orders) else 0 end) as pending_orders,
                     (case when orders.status = 1 then COUNT(orders) else 0 end) as successfull_orders,
                     (case when orders.status = 2 then COUNT(orders) else 0 end) as cancelled_orders")
      .joins('INNER JOIN orders ON orders.customer_id = customers.id')
      .group('customers.id, orders.status').active

    @q = if params[:q]&.[](:s).blank?
           cus.order(created_at: :desc).ransack(params[:q])
         else
           cus.ransack(params[:q])
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
    @customer = current_retailer.customers.active.find(params[:id])

    render json: { customer: @customer }
  end

  private

    def check_ownership
      customer = Customer.find_by(web_id: params[:id])
      redirect_to retailers_dashboard_path(@retailer) unless customer && @retailer.customers.exists?(customer.id)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find_by(web_id: params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def customer_params
      params.require(:customer).permit(
        :email,
        :phone,
        :id_type,
        :id_number,
        :address,
        :city,
        :state,
        :zip_code,
        :country_id,
        :first_name,
        :last_name,
        :notes
      )
    end
end
