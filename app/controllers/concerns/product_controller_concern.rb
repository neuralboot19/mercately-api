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
end
