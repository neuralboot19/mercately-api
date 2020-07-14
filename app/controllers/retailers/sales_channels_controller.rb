class Retailers::SalesChannelsController < RetailersController
  before_action :check_ownership, only: [:show, :edit, :update, :destroy]
  before_action :set_sales_channel, only: [:show, :edit, :update, :destroy]

  def index
    @sales_channels = current_retailer.sales_channels.page(params[:page])
  end

  def show
  end

  def new
    @sales_channel = SalesChannel.new
  end

  def edit
  end

  def create
    @sales_channel = current_retailer.sales_channels.new(sales_channel_params)

    if @sales_channel.save
      redirect_to retailers_sales_channel_path(current_retailer, @sales_channel), notice:
        'Canal de venta creado con éxito.'
    else
      render :new
    end
  end

  def update
    if @sales_channel.update(sales_channel_params)
      redirect_to retailers_sales_channel_path(current_retailer, @sales_channel), notice:
        'Canal de venta actualizado con éxito.'
    else
      render :edit
    end
  end

  def destroy
    if @sales_channel.destroy
      redirect_to retailers_sales_channels_path(current_retailer), notice:
        'Canal de venta eliminado con éxito.'
    else
      redirect_to retailers_sales_channels_path(current_retailer), notice:
        @sales_channel.errors['base'].join(', ')
    end
  end

  private

    def sales_channel_params
      params.require(:sales_channel).permit(:title)
    end

    def check_ownership
      sales_channel = current_retailer.sales_channels.find_by_web_id(params[:id])
      redirect_to retailers_dashboard_path(current_retailer) unless sales_channel
    end

    def set_sales_channel
      @sales_channel = SalesChannel.find_by_web_id(params[:id])
    end
end
