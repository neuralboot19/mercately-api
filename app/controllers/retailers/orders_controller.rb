class Retailers::OrdersController < RetailersController
  before_action :set_order, only: [:show, :edit, :update, :destroy]

  # GET /orders
  def index
    @orders = Order.all
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
    @order = Order.new(order_params)

    if @order.save
      redirect_to retailers_order_path(@retailer.slug, @order), notice: 'Order was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /orders/1
  def update
    if @order.update(order_params)
      redirect_to retailers_order_path(@retailer.slug, @order), notice: 'Order was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /orders/1
  def destroy
    @order.destroy
    redirect_to retailers_orders_url(@retailer.slug), notice: 'Order was successfully destroyed.'
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def order_params
      params.require(:order).permit(
        :status,
        :customer_id,
        order_items_attributes: [
          :id,
          :product_id,
          :quantity,
          :unit_price,
          :created_at,
          :updated_at,
          :_destroy
        ]
      )
    end
end
