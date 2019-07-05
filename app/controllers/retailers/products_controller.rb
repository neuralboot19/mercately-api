class Retailers::ProductsController < RetailersController
  before_action :set_product, only: [:show, :edit, :update, :destroy, :product_with_variations]
  before_action :compile_variation_images, only: [:create, :update]

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
    @product = Product.new(product_params)
    check_for_errors(params)

    if @product.errors.present?
      render :new
      return
    end

    params[:product][:images] = process_images(params[:product][:images])
    @product.retailer_id = @retailer.id

    @product.ml_attributes = process_attributes(params[:product][:ml_attributes]) if
      params[:product][:ml_attributes].present?

    if @product.save
      upload_variations
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

    if @product.update(product_params)
      upload_variations
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

  def product_with_variations
    render json: {
      product: @product,
      variations: @product.product_variations,
      template: @product.category.clean_template_variations
    }
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

      category = Category.find(params[:product][:category_id])
      params[:product][:variations].each do |var|
        temp_var = {
          attribute_combinations: [],
          picture_ids: []
        }

        var[1].each do |t|
          if category.template.any? { |temp| temp['id'] == t[0] && temp['tags']['allow_variations'] }
            temp_var[:attribute_combinations] << { id: t[0], value_id: t[1] }
          else
            temp_var[t[0]] = t[1]
          end
        end
        @variations << temp_var
      end
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

      category = Category.find(category_id)
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

    def upload_variations
      return unless @variations.present?

      if action_name == 'new' || action_name == 'create'
        create_variations
      elsif action_name == 'edit' || action_name == 'update'
        update_variations
      end

      @product.upload_variations_to_ml
    end

    def create_variations
      @variations.each do |var|
        @product.product_variations.create(data: var)
      end
    end

    def update_variations
      @variations.each do |var|
        if var['id'].present?
          @product.product_variations.find_by(variation_meli_id: var['id']).update(data: var)
        else
          @product.product_variations.create(data: var)
        end
      end
      delete_variations
    end

    def delete_variations
      current_variations = @product.product_variations.pluck(:variation_meli_id).compact
      variation_ids = @variations.map { |vari| vari['id'].to_i }.compact

      current_variations -= variation_ids if current_variations.present?

      return unless current_variations.present?

      @product.product_variations.where(variation_meli_id: current_variations).delete_all
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
                                      images: [],
                                      ml_attributes: [])
    end
end
