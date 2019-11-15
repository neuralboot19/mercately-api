module ProductHelper
  def ordered_images
    return [] if @product.images.blank?

    images = @product.images.to_a
    images = images.unshift(images.detect { |img| img.id == @product.main_picture_id }).uniq if
      @product.main_picture_id

    images
  end

  def disabled_meli_statuses
    disabled = %w[payment_required under_review inactive]

    return disabled + %w[active paused closed] if
      @product.status == 'archived' || disabled.include?(@product.meli_status)
    return disabled if @product.meli_status == 'active'
    return disabled + %w[paused] if @product.meli_status == 'closed'
    return disabled + %w[closed] if @product.meli_status == 'paused'
  end

  def manual_statuses(product)
    disabled = %w[payment_required under_review inactive]
    return [] if disabled.include?(product.meli_status)

    statuses = [
      {
        status: 'active',
        label: 'Activo'
      },
      {
        status: 'paused',
        label: 'Pausado'
      },
      {
        status: 'closed',
        label: 'Cerrado'
      }
    ]

    return statuses - [statuses[1], statuses[2]] if %w[paused closed].include?(product.meli_status)

    statuses - [statuses[0]]
  end

  def categories_filter(retailer)
    category_ids = retailer.products.distinct(:category_id).pluck(:category_id)
    categories = Category.where(id: category_ids)
    categories.map { |cat| [cat.name, cat.id] }
  end

  def ordering_options
    [
      {
        value: 'created_at asc',
        label: 'Fecha de creación Asc'
      },
      {
        value: 'created_at desc',
        label: 'Fecha de creación Desc'
      },
      {
        value: 'title asc',
        label: 'Nombre del producto Asc'
      },
      {
        value: 'title desc',
        label: 'Nombre del producto Desc'
      },
      {
        value: 'sold_quantity desc',
        label: 'Más vendidos'
      },
      {
        value: 'sold_quantity asc',
        label: 'Menos vendidos'
      },
      {
        value: 'price desc',
        label: 'Mayor precio'
      },
      {
        value: 'price asc',
        label: 'Menor precio'
      },
      {
        value: 'available_quantity desc',
        label: 'Mayor cantidad disponible'
      },
      {
        value: 'available_quantity asc',
        label: 'Menor cantidad disponible'
      }
    ]
  end
end
