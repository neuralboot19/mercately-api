module ProductModelConcern
  extend ActiveSupport::Concern

  # Chequea si es posible mandar la informacion a ML
  def able_to_send_to_ml?
    meli_product_id.present? || upload_product == true
  end

  # Chequea si las imagenes son requeridas o no en la creacion y edicion del producto
  def mandatory_images?
    return false if retailer&.meli_retailer.blank? || upload_product == false

    if new_record?
      required_images_on_create?
    else
      required_images_on_update?
    end
  end

  # Chequea si las imagenes son requeridas o no en la creacion del producto
  def required_images_on_create?
    incoming_images.blank? && upload_product == true
  end

  # Chequea si las imagenes son requeridas o no en la edicion del producto
  def required_images_on_update?
    incoming_images.blank? && all_images_deleted? &&
      (meli_product_id.present? || upload_product == true)
  end

  # Chequea si las variaciones son necesarias para la categoria seleccionada
  def check_for_variations?
    return false if category_id.blank?

    category = Category.active.find(category_id)
    return false if category.blank?

    template = category.clean_template_variations
    template.any? { |temp| temp['tags']['allow_variations'] }
  end

  # Revisa si la cantidad de imagenes a eliminar es igual al total de imagenes que tiene
  # el producto
  def all_images_deleted?
    total = 0
    deleted_images&.each do
      total += 1
    end

    total == images.size
  end
end