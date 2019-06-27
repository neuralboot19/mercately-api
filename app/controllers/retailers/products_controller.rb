class Retailers::ProductsController < RetailersController
  before_action :set_product, only: [:show, :edit, :update, :destroy]
  before_action :set_categories, only: [:show, :edit, :update, :new]

  # GET /products
  def index
    @products = Product.where(retailer_id: @retailer.id).with_attached_images.page(params[:page])
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
    params[:product][:images] = process_images(params[:product][:images])
    @product = Product.new(product_params)
    @product.retailer_id = @retailer.id
    if @product.save
      redirect_to retailers_product_path(@retailer, @product), notice: 'Product was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /products/1
  def update
    params[:product][:images] = process_images(params[:product][:images])
    if @product.update(product_params)
      redirect_to retailers_product_path(@retailer, @product), notice: 'Product was successfully updated.'
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

    def process_images(images)
      return [] unless images.present?

      output_images = []
      images.each do |img|
        tempfile = MiniMagick::Image.open(File.open(img.tempfile))
        tempfile.resize '500x500'
        img.tempfile = tempfile.tempfile
        output_images << img
      end

      output_images
    end

    def set_categories
      @categories = Category.all.pluck(:name, :id)
    end

    # Only allow a trusted parameter "white list" through.
    def product_params
      params.require(:product).permit(:title,
                                      :subtitle,
                                      :category_id,
                                      :price,
                                      :available_quantity,
                                      :buying_mode,
                                      :condition,
                                      :description,
                                      images: [])
    end
end
