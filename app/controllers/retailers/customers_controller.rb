# frozen_string_literal: true

class Retailers::CustomersController < RetailersController
  include CustomerControllerConcern
  before_action :check_ownership, only: [:show, :edit, :update, :destroy]
  before_action :set_customer, only: [:show, :edit, :update, :destroy]

  def index
    cus = Customer.eager_load(:orders_success).active.where(retailer_id: current_retailer.id)

    @q = if params[:q]&.[](:s).blank?
           cus.order(created_at: :desc).ransack(params[:q])
         else
           cus.ransack(params[:q])
         end

    @customers = @q.result.page(params[:page])
    ActiveRecord::Precounter.new(@customers).precount(:orders_pending, :orders_success, :orders_cancelled)
    @export_params = export_params
  end

  def export
    Customers::ExportCustomersJob.perform_later(current_retailer_user.retailer.id,
                                                current_retailer_user.email,
                                                export_params)
    redirect_to(retailers_customers_path(current_retailer),
                notice: 'La exportación está en proceso, recibirá un mail cuando esté lista.')
  end

  def show
  end

  def new
    @customer = Customer.new
  end

  def edit
    edit_setup
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
        :notes,
        :whatsapp_opt_in
      )
    end

    def export_params
      params.permit('q' => %w[first_name_or_last_name_or_phone_or_email_cont s])
    end
end
