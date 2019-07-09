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
      @total_available = 0
      @total_sold = 0

      category = Category.find(params[:product][:category_id])
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

      @product.reload
      @product.upload_variations_to_ml
    end

    def create_variations
      @variations.each do |var|
        @product.product_variations.create(data: var)
      end
    end

    def update_variations
      @variations.each do |var|
        if var['id'].present? && var['id'] != 'undefined'
          @product.product_variations.find_by(variation_meli_id: var['id']).update(data: var)
        elsif var['variation_id'].present? && var['variation_id'] != 'undefined'
          @product.product_variations.find(var['variation_id']).update(data: var)
        else
          @product.product_variations.create(data: var)
        end
      end
      delete_variations
      delete_variations_by_ids
    end

    def delete_variations
      current_variations = @product.product_variations.pluck(:variation_meli_id).compact
      variation_ids = @variations.map { |vari| vari['id'].to_i }.compact

      current_variations -= variation_ids if current_variations.present?

      return unless current_variations.present?

      @product.product_variations.where(variation_meli_id: current_variations).delete_all if
        current_variations.present?
    end

    def delete_variations_by_ids
      current_variation_ids = @product.product_variations.pluck(:id).compact
      variation_merc_ids = @variations.map { |vari| vari['variation_id'].to_i }.compact

      current_variation_ids -= variation_merc_ids if current_variation_ids.present?

      return unless current_variation_ids.present?

      @product.product_variations.where(id: current_variation_ids).delete_all if
        current_variation_ids.present?
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
