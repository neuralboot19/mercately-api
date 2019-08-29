class Retailers::ProductsController < RetailersController
  before_action :set_product, only: [:show, :edit, :update, :product_with_variations, :price_quantity]
  before_action :compile_variation_images, only: [:create, :update]
  before_action :set_products, only: [:index]
  before_action :update_meli_status, only: [:update]

  # GET /products
  def index
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
    check_for_errors(params)

    if @product.errors.present?
      render :new
      return
    end

    @product.retailer_id = @retailer.id

    @product.ml_attributes = process_attributes(params[:product][:ml_attributes]) if
      params[:product][:ml_attributes].present?

    if @product.save
      @product.update_main_picture(params[:new_main_image_name]) if params[:new_main_image].present?
      @product.reload
      @product.upload_ml
      @product.upload_variations(action_name, @variations)
      redirect_to retailers_product_path(@retailer, @product), notice: 'Product was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /products/1
  def update
    check_for_errors(params)

    if @product.errors.present?
      render :edit
      return
    end

    params[:product][:images] = process_images(params[:product][:images])
    @product.ml_attributes = process_attributes(params[:product][:ml_attributes]) if
      params[:product][:ml_attributes].present?

    past_meli_status = @product.meli_status

    if @product.update(product_params)
      @product.update_main_picture(params[:new_main_image_name]) if params[:new_main_image].present?
      @product.delete_images(params[:product][:delete_images], @variations, past_meli_status) if
        params[:product][:delete_images].present?
      @product.reload
      @product.update_ml_info(past_meli_status)
      @product.upload_variations(action_name, @variations)
      redirect_to retailers_product_path(@retailer, @product), notice: 'Product was successfully updated.'
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

  private

    def update_meli_status
      params['product']['meli_status'] = 'closed' if params['product']['status'] == 'archived'
    end

    def set_products
      @products = Product.retailer_products(@retailer.id, params['status'])
        .with_attached_images.page(params[:page])
    end

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
      @total_sold = 0

      category = Category.active_categories.find(params[:product][:category_id])
      params[:product][:variations].each do |var|
        temp_var = build_variation(var[1], category)
        temp_var['price'] = params[:product][:price]
        @variations << temp_var
      end

      params[:product][:available_quantity] = @total_available
      params[:product][:sold_quantity] = @total_sold
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
        @total_sold += t[1].to_i if t[0] == 'sold_quantity'
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
      output_attributes = []

      attributes.each do |atr|
        output_attributes << { id: atr[0], value_name: atr[1] }
      end

      output_attributes
    end

    def check_for_variations(category_id)
      return false if category_id.blank?

      category = Category.active_categories.find(category_id)
      return false if category.blank?

      template = category.clean_template_variations
      template.any? { |temp| temp['tags']['allow_variations'] }
    end

    def check_for_errors(params)
      if check_for_variations(params[:product][:category_id]) && params[:product][:variations].blank?
        @product.errors.add(:base, 'Debe agregar al menos una variación.')
      end

      return if params[:product][:images].present? || (action_name == 'edit' || action_name == 'update')

      @product.errors.add(:base, 'Debe agregar entre 1 y 10 imágenes.')
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
end
