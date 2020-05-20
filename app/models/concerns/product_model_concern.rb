module ProductModelConcern
  extend ActiveSupport::Concern

  # Chequea si es posible mandar la informacion a ML
  def able_to_send_to_ml?
    meli_product_id.present? || upload_product == true
  end

  # Chequea si las imagenes son requeridas o no en la creacion y edicion del producto
  def mandatory_images?
    return false if not_necessary_upload?

    if new_record?
      required_images_on_create?
    else
      required_images_on_update?
    end
  end

  # Chequea si las imagenes son requeridas o no en la creacion del producto
  def required_images_on_create?
    (incoming_images.blank? && main_image.blank?) && (upload_product == true || upload_to_facebook == true)
  end

  # Chequea si las imagenes son requeridas o no en la edicion del producto
  def required_images_on_update?
    (incoming_images.blank? &&
      main_image.blank?) &&
      all_images_deleted? &&
      ((meli_product_id.present? ||
      upload_product == true) ||
      (facebook_product_id.present? ||
      upload_to_facebook == true ||
      connected_to_facebook == true))
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
    deleted_images&.each do |img|
      total += 1 if img[1].present?
    end

    total == images.size
  end

  # Chequea si la foto principal es requerida
  def main_image_present?
    return main_image.blank? && incoming_images.present? if new_record?

    main_image.blank? && changed_main_image.blank? && old_main_image_deleted?
  end

  # Chequea si la actual foto principal sera eliminada
  def old_main_image_deleted?
    deleted_images&.each do |img|
      return true if img[1].to_i == main_picture_id
    end

    false
  end

  # Asigna la nueva imagen principal en la edicion del producto
  def assign_main_picture
    self.main_picture_id = changed_main_image if changed_main_image.present?
  end

  # Chequea si la imagen esta realmente almacenada en Cloudinary
  def check_cloudinary_image(img)
    return unless img.present?

    begin
      file = "http://res.cloudinary.com/#{ENV['CLOUDINARY_CLOUD_NAME']}/image/upload/#{img.key}"
      MiniMagick::Image.open(file)
      return true
    rescue OpenURI::HTTPError
      images.where(blob_id: img.id).purge
      return false
    end
  end

  # Setea en nil el code del producto si viene vacio
  def nullify_code
    self.code = nil if code.blank?
  end

  # Suma la cantidad de items vendidos en el rango de fechas
  def range_total_sold(start_date, end_date)
    order_items.includes(:order).where(orders: { status: 'success', created_at:
      start_date..end_date }).sum(&:quantity)
  end

  # Suma la ganancia de los items vendidos en el rango de fechas
  def range_total_earned(start_date, end_date)
    order_items.includes(:order).where(orders: { status: 'success', created_at:
      start_date..end_date }).sum('order_items.quantity * order_items.unit_price')
  end

  def not_necessary_upload?
    (retailer&.meli_retailer.blank? ||
      upload_product == false) &&
      (retailer&.facebook_catalog.blank? ||
      retailer.facebook_catalog.connected? == false ||
      upload_to_facebook == false)
  end
end
