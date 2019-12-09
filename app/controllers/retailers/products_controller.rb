class Retailers::ProductsController < RetailersController
  include ProductControllerConcern
  before_action :set_product, only: [:show, :edit, :update, :product_with_variations, :price_quantity,
                                     :archive_product, :reactive_product, :upload_product_to_ml,
                                     :update_meli_status]
  before_action :compile_variations, only: [:create, :update]

  def index
    @q = if params[:q]&.[](:s).blank?
           current_retailer.products.order(created_at: :desc).preload(:category, :questions).ransack(params[:q])
         else
           current_retailer.products.preload(:category, :questions).ransack(params[:q])
         end

    @products = @q.result.with_attached_images.page(params[:page])
  end

  def show
  end

  def new
    @product = Product.new
  end

  def edit
  end

  def create
    params[:product][:images] = process_images(params[:product][:images])
    @product = current_retailer.products.new(product_params.except(:images))
    assign_attributes

    unless @product.valid?
      render :new
      return
    end

    @product.images = params[:product][:images]
    if @product.save
      @product.update_main_picture if @main_image
      @product.reload
      @product.upload_ml
      @product.upload_variations(action_name, @variations)
      redirect_to retailers_product_path(@retailer.slug, @retailer.web_id, @product), notice:
        'Producto creado con éxito.'
    else
      render :new
    end
  end

  def update
    params[:product][:images] = process_images(params[:product][:images])
    params['product']['meli_status'] = 'closed' if set_meli_status_closed?
    @product.deleted_images = params[:product][:delete_images]
    @product.changed_main_image = params[:main_picture]
    assign_attributes

    unless @product.valid?
      render :edit
      return
    end

    if @product.update(product_params)
      update_meli_info
      redirect_to retailers_product_path(@retailer.slug, @retailer.web_id, @product), notice:
        'Producto actualizado con éxito.'
    else
      render :edit
    end
  end

  def product_with_variations
    render json: {
      product: @product,
      variations: @product.product_variations,
      template: @product.category.clean_template_variations
    }
  end

  def price_quantity
    render json: {
      id: @product.id,
      price: @product.price,
      quantity: @product.available_quantity,
      variations: @product.product_variations
    }
  end

  def archive_product
    past_meli_status = @product.meli_status
    @product.status = 'archived'
    @product.meli_status = 'closed' if @product.meli_product_id

    if @product.save
      @product.update_ml_info(past_meli_status) if @product.meli_product_id
      redirect_back fallback_location: retailers_product_path(@retailer.slug, @retailer.web_id, @product),
                    notice: 'Producto archivado con éxito.'
    else
      render :edit
    end
  end

  def reactive_product
    @product.upload_product = true
    @product.status = 'active'
    @product.meli_status = 'active' if @product.meli_product_id

    if @product.save
      @product.upload_ml if @product.meli_product_id
      redirect_back fallback_location: retailers_product_path(@retailer.slug, @retailer.web_id, @product),
                    notice: 'Producto reactivado con éxito.'
    else
      render :edit
    end
  end

  def upload_product_to_ml
    @product.upload_product = true

    if @product.product_without_images?
      render :edit
      return
    end

    if @product.save
      @product.upload_ml
      @product.upload_variations(action_name, @product.product_variations)
      redirect_to retailers_products_path(@retailer.slug, @retailer.web_id, q: { 'status_eq': 0, 's':
        'created_at desc' }), notice: 'Producto publicado con éxito.'
    else
      render :edit
    end
  end

  def update_meli_status
    past_meli_status = @product.meli_status
    @product.meli_status = params[:status]

    if @product.save
      @product.update_ml_info(past_meli_status)
      redirect_back fallback_location: retailers_product_path(@retailer.slug, @retailer.web_id, @product),
                    notice: 'Estado actualizado con éxito.'
    else
      render :edit
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
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
                                      :main_picture_id,
                                      :sold_quantity,
                                      :status,
                                      :meli_status,
                                      :code,
                                      images: [],
                                      ml_attributes: [])
    end
end
