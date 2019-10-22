class Retailers::ProductsController < RetailersController
  include ProductControllerConcern
  before_action :set_product, only: [:show, :edit, :update, :product_with_variations, :price_quantity, :archive_product,
                                     :upload_product_to_ml]
  before_action :compile_variation_images, only: [:create, :update]

  def index
    @products = current_retailer.products.preload(:category, :questions).where(status: params['status'])
      .with_attached_images.page(params[:page])
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
    @product.upload_product = convert_to_boolean(params[:product][:upload_product])
    @product.incoming_images = params[:product][:images]
    @product.incoming_variations = @variations

    unless @product.valid?
      render :new
      return
    end

    @product.images = params[:product][:images]
    @product.ml_attributes = process_attributes(params[:product][:ml_attributes])

    if @product.save
      @product.update_main_picture(params[:new_main_image_name]) if params[:new_main_image].present?
      @product.reload
      @product.upload_ml
      @product.upload_variations(action_name, @variations)
      redirect_to retailers_product_path(@retailer, @product), notice: 'Producto creado con éxito.'
    else
      render :new
    end
  end

  def update
    params[:product][:images] = process_images(params[:product][:images])
    params['product']['meli_status'] = 'closed' if set_meli_status_closed?
    @product.upload_product = convert_to_boolean(params[:product][:upload_product])
    @product.incoming_images = params[:product][:images]
    @product.deleted_images = params[:product][:delete_images]
    @product.incoming_variations = @variations

    unless @product.valid?
      render :edit
      return
    end

    @product.ml_attributes = process_attributes(params[:product][:ml_attributes])

    if @product.update(product_params)
      update_meli_info
      redirect_to retailers_product_path(@retailer, @product), notice: 'Producto actualizado con éxito.'
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
    @product.meli_status = 'closed' if @product.meli_product_id.present?

    if @product.save
      @product.update_ml_info(past_meli_status) if @product.meli_product_id.present?
      redirect_to retailers_product_path(@retailer, @product), notice: 'Producto archivado con éxito.'
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
      main_picture = select_main_picture
      @product.update_main_picture(main_picture.filename.to_s) if main_picture.present?
      @product.upload_ml
      @product.upload_variations(action_name, @product.product_variations)
      redirect_to retailers_products_path(@retailer, status: @product.status), notice: 'Producto publicado con éxito.'
    else
      render :edit
    end
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

    def compile_variation_images
      return [] unless params[:product][:variations].present?

      @variations = []
      @total_available = 0

      category = Category.active.find(params[:product][:category_id])
      params[:product][:variations].each do |var|
        temp_var = build_variation(var[1], category)
        temp_var['price'] = params[:product][:price]
        @variations << temp_var
      end

      params[:product][:available_quantity] = @total_available
    end

    def build_variation(variation, category)
      temp_var = {
        attribute_combinations: [],
        picture_ids: []
      }

      variation.each do |t|
        temp_aux = category.template.select { |temp| temp['id'] == t[0] && temp['tags']['allow_variations'] }
        temp_var = fill_temp(temp_aux, temp_var, t)

        @total_available += t[1].to_i if t[0] == 'available_quantity'
      end

      temp_var
    end

    def fill_temp(temp_aux, temp_var, record)
      if temp_aux.present?
        temp_var[:attribute_combinations] << if temp_aux.first['value_type'] == 'list'
                                               { id: record[0], value_id: record[1] }
                                             else
                                               { id: record[0], value_name: record[1] }
                                             end
      else
        temp_var[record[0]] = record[1]
      end

      temp_var
    end

    def process_attributes(attributes)
      return @product.ml_attributes if attributes.blank?

      output_attributes = []

      attributes.each do |atr|
        output_attributes << { id: atr[0], value_name: atr[1] }
      end

      output_attributes
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
                                      images: [],
                                      ml_attributes: [])
    end

    def update_meli_info
      past_meli_status = @product.meli_status
      @product.update_main_picture(params[:new_main_image_name]) if params[:new_main_image].present?
      @product.delete_images(params[:product][:delete_images], @variations, past_meli_status) if
      params[:product][:delete_images].present?
      @product.reload
      @product.update_ml_info(past_meli_status)
      @product.upload_ml if @product.meli_product_id.blank? && @product.upload_product == true
      @product.upload_variations(action_name, @variations)
      @product.update_status_publishment
    end
end
