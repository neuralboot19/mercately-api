module ProductControllerConcern
  extend ActiveSupport::Concern

  # Convierte el attr enviado a su representacion en boolean
  def convert_to_boolean(attribute)
    ActiveModel::Type::Boolean.new.cast(attribute)
  end

  # Chequea si se puede setear en closed el meli_status del producto
  def set_meli_status_closed?
    params['product']['status'] == 'archived' && @product.meli_product_id.present?
  end

  # Asigna atributos comunes en los metodos create y update
  def assign_attributes
    @product.attributes = { upload_product: convert_to_boolean(params[:product][:upload_product]), incoming_images:
      params[:product][:images], incoming_variations: @variations, main_image: @main_image, ml_attributes:
      process_attributes(params[:product][:ml_attributes]), upload_to_facebook:
      convert_to_boolean(params[:product][:upload_to_facebook]), avoid_update_inventory: true,
      url: params[:product][:url] }
  end

  # Ejecuta la logica posterior al update del producto
  def update_meli_info
    @fail_ml = false
    updated_info = @product.update_ml_info(@past_meli_status)
    uploaded_info = @product.upload_ml if @product.meli_product_id.blank? && @product.upload_product == true
    @product.upload_variations(action_name, @variations)
    @product.update_status_publishment

    @fail_ml = true if updated_info&.[](:updated) == false || uploaded_info&.[](:uploaded) == false
  end

  # procesa las imagenes a guardar para darles las dimensiones correctas
  def process_images(images)
    return [] unless images.present?

    output_images = []
    images.each do |img|
      tempfile = MiniMagick::Image.open(File.open(img[1].tempfile))
      tempfile.resize '500x500'
      img[1].tempfile = tempfile.tempfile

      if img[0] == params[:new_main_picture]
        @main_image = img[1]
        next
      end

      output_images << img[1]
    end

    output_images
  end

  # Compila las variaciones para guardar y enviar a ML con el formato correcto
  def compile_variations
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

  # Construye cada variacion individual
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

  # Llena la variacion con la data debida
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

  # Procesa los atributos editables para el usuario para mostrarlos en el show
  def process_attributes(attributes)
    return @product.ml_attributes if attributes.blank?

    output_attributes = []

    attributes.each do |atr|
      output_attributes << { id: atr[0], value_name: atr[1] }
    end

    output_attributes
  end

  def post_product_to_ml
    @fail_ml = false

    uploaded_info = @product.upload_ml
    @product.upload_variations(action_name, @variations)

    @fail_ml = true if uploaded_info&.[](:uploaded) == false
  end

  def post_product_to_facebook
    @fail_fb = false

    uploaded_fb_info = @product.upload_facebook

    @fail_fb = true if uploaded_fb_info&.[](:success) == false
  end

  def notice_to_show
    return 'Error: tu producto no pudo ser publicado en MercadoLibre y Facebook.' if @fail_ml && @fail_fb
    return 'Error: tu producto no pudo ser publicado en Facebook.' if @fail_fb
    return 'Error: tu producto no pudo ser publicado en MercadoLibre.' if @fail_ml
    'Producto creado con éxito.'
  end

  def update_facebook_product
    @fail_fb = false

    updated_fb_info = @product.update_facebook_product

    @fail_fb = true if updated_fb_info&.[](:success) == false
  end

  def notice_to_show_update
    return 'Error: tu producto no pudo ser actualizado en MercadoLibre y Facebook.' if @fail_ml && @fail_fb
    return 'Error: tu producto no pudo ser actualizado en Facebook.' if @fail_fb
    return 'Error: tu producto no pudo ser actualizado en MercadoLibre.' if @fail_ml
    'Producto actualizado con éxito.'
  end

  def after_update_product
    @past_meli_status = @product.meli_status
    @product.update_main_picture
    @product.delete_images(params[:product][:delete_images], @variations, @past_meli_status) if
    params[:product][:delete_images].present?
    @product.reload
  end
end
