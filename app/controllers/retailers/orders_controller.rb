class Retailers::OrdersController < RetailersController
  before_action :set_order, only: [:show, :edit, :update, :destroy]

  def index
    @orders = Order.retailer_orders(current_retailer.id, params['status'])
      .order('created_at desc').page(params[:page])
  end

  def show
  end

  def new
    @order = Order.new
  end

  def edit
    @customer = @order.customer
  end

  def create
    params[:order][:order_items_attributes] = process_items(params[:order][:order_items_attributes])

    @order = Order.new(order_params)

    if @order.save
      redirect_to retailers_order_path(@retailer.slug, @retailer.web_id, @order), notice: 'Orden creada con éxito.'
    else
      @order.order_items -= @order.order_items.select { |oi| oi.product.blank? }
      render :new
    end
  end

  def update
    params[:order][:order_items_attributes] = process_items(params[:order][:order_items_attributes])

    if @order.update(order_params)
      redirect_to retailers_order_path(@retailer.slug, @retailer.web_id, @order), notice: 'Orden actualizada con éxito.'
    else
      render :edit
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
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
          :first_name,
          :last_name,
          :email,
          :phone,
          :retailer_id
        ]
      )
    end
end
