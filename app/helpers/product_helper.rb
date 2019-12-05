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
        value: 'title asc',
        label: 'Nombre del producto Asc'
      },
      {
        value: 'title desc',
        label: 'Nombre del producto Desc'
      },
      {
        value: 'sort_by_order_items_count desc',
        label: 'Más vendidos'
      },
      {
        value: 'sort_by_order_items_count asc',
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
        value: 'sort_by_earned desc',
        label: 'Mayor ganancia'
      },
      {
        value: 'sort_by_earned asc',
        label: 'Menor ganancia'
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

  def successfull_order_items_count(product)
    product.order_items.includes(:order).where(orders: { status: 'success' }).count
  end

  def total_sold(product)
    product.order_items.includes(:order).where(orders: { status: 'success' }).sum(&:quantity)
  end
end
