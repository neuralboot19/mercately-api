class Retailers::ProductsController < RetailersController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  # GET /products
  def index
    @products = Product.where(retailer_id: current_retailer_user.retailer_id)
  end

  # GET /products/1
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products
  def create
    @product = Product.new(product_params)
    @product.retailer_id = @retailer.id

    if @product.save
      redirect_to retailers_product_path(@retailer.slug, @product), notice: 'Product was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /products/1
  def update
    if @product.update(product_params)
      redirect_to retailers_product_path(@retailer.slug, @product), notice: 'Product was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /products/1
  def destroy
    @product.destroy
    redirect_to retailers_products_path, notice: 'Product was successfully destroyed.'
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def product_params
      params.require(:product).permit(:title,
                                      :category_id,
                                      :price,
                                      :available_quantity,
                                      :buying_mode,
                                      :condition,
                                      :description)
    end
end
