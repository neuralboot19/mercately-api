class Retailers::OrdersController < RetailersController
  before_action :set_order, only: [:show, :edit, :update, :destroy]

  # GET /orders
  def index
    @orders = Order.joins(:customer).where('customers.retailer_id = ?', @retailer.id.to_s).page(params[:page])
  end

  # GET /orders/1
  def show
  end

  # GET /orders/new
  def new
    @order = Order.new
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders
  def create
    params[:order][:order_items_attributes] = process_items(params[:order][:order_items_attributes])

    @order = Order.new(order_params)

    if @order.save
      redirect_to retailers_order_path(@retailer.slug, @order), notice: 'Order was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /orders/1
  def update
    params[:order][:order_items_attributes] = process_items(params[:order][:order_items_attributes])

    if @order.update(order_params)
      redirect_to retailers_order_path(@retailer.slug, @order), notice: 'Order was successfully updated.'
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
        ]
      )
    end
end
