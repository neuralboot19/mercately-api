class Retailers::ProductsController < RetailersController
  include ProductControllerConcern
  before_action :check_ownership, only: [:show, :edit, :update, :archive_product, :reactive_product,
                                         :upload_product_to_ml, :update_meli_status]
  before_action :set_product, only: [:show, :edit, :update, :archive_product, :reactive_product,
                                     :upload_product_to_ml, :update_meli_status]
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
    return unless current_retailer.facebook_catalog&.connected?

    @show_phone_message = true

    if current_retailer.retailer_number.present?
      @product.url = "https://api.whatsapp.com/send?l=es&phone=#{current_retailer.retailer_number}"
      @show_phone_message = false
    end
  end

  def edit
    return unless current_retailer.facebook_catalog&.connected?

    @show_phone_message = true if current_retailer.retailer_number.blank? && @product.url.blank?

    if current_retailer.retailer_number.present? && @product.url.blank?
      @product.url = "https://api.whatsapp.com/send?l=es&phone=#{current_retailer.retailer_number}"
      @show_phone_message = false
    end
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
      @product.update_main_picture
      @product.reload
      post_product_to_ml
      post_product_to_facebook
      redirect_to retailers_product_path(@retailer, @product), notice: notice_to_show
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
      after_update_product
      update_meli_info
      update_facebook_product
      redirect_to retailers_product_path(@retailer, @product), notice: notice_to_show_update
    else
      render :edit
    end
  end

  def product_with_variations
    @product = @retailer.products.find(params[:id])

    render json: {
      product: @product,
      variations: @product.product_variations,
      template: @product.category.clean_template_variations
    }
  end

  def price_quantity
    @product = @retailer.products.find(params[:id])

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
    notice = 'Producto archivado con éxito.'

    if @product.save
      updated_info = @product.update_ml_info(past_meli_status)
      notice = 'Error: tu producto no pudo ser cerrado en MercadoLibre.' if
        updated_info&.[](:updated) == false
      redirect_back fallback_location: retailers_product_path(@retailer, @product),
                    notice: notice
    else
      render :edit
    end
  end

  def reactive_product
    past_meli_status = @product.meli_status
    @product.status = 'active'
    @product.meli_status = 'active' if @product.meli_product_id
    notice = 'Producto reactivado con éxito.'

    if @product.save
      updated_info = @product.update_ml_info(past_meli_status)
      notice = 'Error: tu producto no pudo ser activado en MercadoLibre.' if
        updated_info&.[](:updated) == false
      redirect_back fallback_location: retailers_product_path(@retailer, @product),
                    notice: notice
    else
      render :edit
    end
  end

  def upload_product_to_ml
    @product.upload_product = true
    notice = 'Producto publicado con éxito.'

    if @product.product_without_images?
      render :edit
      return
    end

    if @product.save
      uploaded_info = @product.upload_ml
      @product.upload_variations(action_name, @product.product_variations)
      notice = 'Error: tu producto no pudo ser publicado en MercadoLibre.' if
        uploaded_info&.[](:uploaded) == false
      redirect_to retailers_products_path(@retailer, q: { 'status_eq': 0, 's':
        'created_at desc' }), notice: notice
    else
      render :edit
    end
  end

  def update_meli_status
    past_meli_status = @product.meli_status
    @product.meli_status = params[:status]
    notice = 'Estado actualizado con éxito.'

    if @product.save
      updated_info = @product.update_ml_info(past_meli_status)
      notice = 'Error: estado del producto no pudo ser actualizado en MercadoLibre.' if
        updated_info&.[](:updated) == false
      redirect_back fallback_location: retailers_product_path(@retailer, @product),
                    notice: notice
    else
      render :edit
    end
  end

  private

    def check_ownership
      product = Product.find_by(web_id: params[:id])
      redirect_to retailers_dashboard_path(@retailer) unless product && @retailer.products.exists?(product.id)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find_by(web_id: params[:id])
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
                                      :brand,
                                      :url,
                                      images: [],
                                      ml_attributes: [])
    end
end
