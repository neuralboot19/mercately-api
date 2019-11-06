module ProductHelper
  def ordered_images
    return [] if @product.images.blank?

    images = @product.images.to_a
    images = images.unshift(images.detect { |img| img.id == @product.main_picture_id }).uniq if
      @product.main_picture_id

    images
  end
end
