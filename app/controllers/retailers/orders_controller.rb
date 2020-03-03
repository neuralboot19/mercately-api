class Retailers::OrdersController < RetailersController
  before_action :check_ownership, only: [:show, :edit, :update, :destroy]
  before_action :set_order, only: [:show, :edit, :update, :destroy]

  def index
    @orders = Order.retailer_orders(current_retailer.id, params['status'])
      .order('created_at desc').page(params[:page])
  end

  def show
  end

  def new
    @order = Order.new
    @hide_client_form = true

    if params[:customer_id].present?
      @order.customer_id = params[:customer_id]
      customer = Customer.find(params[:customer_id])
      @hide_client_form = false unless customer.valid_customer?
    elsif params[:first_name].present?
      @order.customer = Customer.new
      @order.customer.first_name = params[:first_name]
      @order.customer.last_name = params[:last_name]
      @order.customer.email = params[:email]
      @order.customer.phone = params[:phone]
      @hide_client_form = false
    end
  end

  def edit
    @customer = @order.customer
    @hide_client_form = true
  end

  def create
    params[:order][:order_items_attributes] = process_items(params[:order][:order_items_attributes])

    @order = Order.new(order_params)

    if @order.save
      redirect_to retailers_order_path(@retailer, @order), notice: 'Orden creada con éxito.'
    else
      @order.order_items -= @order.order_items.select { |oi| oi.product.blank? }
      render :new
    end
  end

  def update
    params[:order][:order_items_attributes] = process_items(params[:order][:order_items_attributes])

    if @order.update(order_params)
      redirect_to retailers_order_path(@retailer, @order), notice: 'Orden actualizada con éxito.'
    else
      render :edit
    end
  end

  private

    def check_ownership
      order = Order.find_by(web_id: params[:id])
      redirect_to retailers_dashboard_path(@retailer) unless order && order.retailer.id == @retailer.id
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find_by(web_id: params[:id])
    end

    def process_items(items)
      output_items = []

      items.each do |oi|
        output_items << oi[1] if oi[1]['quantity'].present? && oi[1]['unit_price'].present?
      end

      output_items
    end

    # Only allow a trusted parameter "white list" through.
    def order_params
      params.require(:order).permit(
        :status,
        :customer_id,
        :merc_status,
        :feedback_reason,
        :feedback_rating,
        :feedback_message,
        order_items_attributes: [
          :id,
          :product_id,
          :quantity,
          :unit_price,
          :created_at,
          :updated_at,
          :product_variation_id,
          :_destroy
        ],
        customer_attributes: [
          :id,
          :email,
          :phone,
          :retailer_id,
          :first_name,
          :last_name
        ]
      )
    end
end
