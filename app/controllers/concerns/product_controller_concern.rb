module ProductControllerConcern
  extend ActiveSupport::Concern

  # Convierte el attr enviado a su representacion en boolean
  def convert_to_boolean(attribute)
    ActiveModel::Type::Boolean.new.cast(attribute)
  end

  # Chequea si las imagenes son requeridas o no en la creacion y edicion del producto
  def mandatory_images?
    if action_name == 'create'
      required_images_on_create?
    elsif action_name == 'update'
      required_images_on_update?
    end
  end

  # Chequea si las imagenes son requeridas o no en la creacion del producto
  def required_images_on_create?
    return false if @retailer.meli_retailer.blank? || @product.upload_product == false
    return true if params[:product][:images].blank? && @product.upload_product == true
  end

  # Chequea si las imagenes son requeridas o no en la edicion del producto
  def required_images_on_update?
    return false if @product.meli_product_id.blank?
    return true if params[:product][:images].blank? && @product.meli_product_id.present?
  end

  # Chequea si se puede setear en closed el meli_status del producto
  def set_meli_status_closed?
    params['product']['status'] == 'archived' && @product.meli_product_id.present?
  end
end
