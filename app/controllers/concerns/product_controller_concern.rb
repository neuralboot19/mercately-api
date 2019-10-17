module ProductControllerConcern
  extend ActiveSupport::Concern

  # Convierte el attr enviado a su representacion en boolean
  def convert_to_boolean(attribute = nil)
    ActiveModel::Type::Boolean.new.cast(attribute)
  end

  # Chequea si las imagenes son requeridas o no en la creacion y edicion del producto
  def mandatory_images?
    return false if @retailer.meli_retailer.blank? ||
                    @product.upload_product == false

    if action_name == 'create'
      required_images_on_create?
    elsif action_name == 'update'
      required_images_on_update?
    end
  end

  # Chequea si las imagenes son requeridas o no en la creacion del producto
  def required_images_on_create?
    params[:product][:images].blank? && @product.upload_product == true
  end

  # Chequea si las imagenes son requeridas o no en la edicion del producto
  def required_images_on_update?
    params[:product][:images].blank? && (@product.meli_product_id.present? ||
      @product.upload_product == true)
  end

  # Chequea si se puede setear en closed el meli_status del producto
  def set_meli_status_closed?
    params['product']['status'] == 'archived' && @product.meli_product_id.present?
  end

  # Busca la imagen principal del producto, y si no tiene, retorna la primera que se le agrego
  def select_main_picture
    if @product.main_picture_id
      @product.images&.find(@product.main_picture_id)
    else
      @product.images&.first
    end
  end
end
