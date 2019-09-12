class Product < ApplicationRecord
  paginates_per 50

  belongs_to :retailer
  belongs_to :category
  has_many :order_items
  has_many :questions
  has_many_attached :images
  has_many :product_variations

  validate :images_count
  validates :meli_product_id, uniqueness: true, allow_nil: true
  validate :ml_status

  enum buying_mode: %w[buy_it_now classified]
  enum condition: %w[new_product used not_specified]
  enum status: %w[active archived], _prefix: true
  enum meli_status: %w[active payment_required paused closed under_review inactive]

  scope :retailer_products, lambda { |retailer_id, status|
    Product.where('retailer_id = ? and status = ?', retailer_id, Product.statuses[status])
  }

  def update_ml(p_ml)
    self.meli_site_id = p_ml['site_id']
    self.meli_start_time = p_ml['start_time']
    self.meli_stop_time = p_ml['stop_time']
    self.meli_end_time = p_ml['end_time']
    self.meli_listing_type_id = p_ml['listing_type_id']
    self.meli_expiration_time = p_ml['expiration_time']
    self.meli_permalink = p_ml['permalink']
    self.meli_product_id = p_ml['id']
    self.ml_attributes = p_ml['attributes']
    self.meli_status = p_ml['status']
    save
  end

  def attach_image(url, filename, index = -1)
    return if ActiveStorage::Blob.joins(:attachments)
      .where(filename: filename, active_storage_attachments:
      {
        name: 'images',
        record_type: 'Product',
        record_id: id
      }).exists?

    tempfile = MiniMagick::Image.open(url)
    tempfile.resize '500x500'
    tempfile.write('./public/upload-' + filename + '.jpg')

    return unless File.exist?(tempfile.path)

    images.attach(io: File.open(tempfile.path), filename: filename)
    update(main_picture_id: images.last.id) if index.zero?

    File.delete('./public/upload-' + filename + '.jpg')
  end

  def update_ml_info(past_meli_status)
    return unless meli_product_id.present?

    reload
    set_active = (meli_status == 'active' || status == 'active') && available_quantity.positive?
    set_ml_products.push_update(self, past_meli_status, set_active)
  end

  def update_main_picture(filename)
    blob_id = ActiveStorage::Blob.joins(:attachments)
      .where(filename: filename, active_storage_attachments:
      {
        name: 'images',
        record_type: 'Product',
        record_id: id
      }).first&.id

    attach_id = images.find_by(blob_id: blob_id)&.id if blob_id.present?
    update(main_picture_id: attach_id) if attach_id.present?

    set_ml_products.load_main_picture(reload, true)
  end

  def upload_ml
    return if retailer.meli_retailer.nil?

    set_ml_products.create(self)
  end

  def upload_variations(action_name, variations)
    return unless variations.present?

    if %w[new create].include?(action_name)
      create_variations(variations)
    elsif %w[edit update].include?(action_name)
      update_variations(variations)
    end

    reload
    upload_variations_to_ml
  end

  def delete_images(delete_images, variations, past_meli_status)
    return unless delete_images.present?

    ids = []
    delete_images.each do |img|
      ids << img[1]
    end

    images.where(id: ids).purge if ids.present?

    return if variations.present?

    reload
    update_ml_info(past_meli_status)
  end

  def disabled_meli_statuses
    disabled = %w[payment_required under_review inactive]

    return disabled + %w[active paused closed] if status == 'archived'
    return disabled + %w[active paused closed] if
      disabled.include? meli_status
    return disabled if meli_status == 'active'
    return disabled + %w[paused] if meli_status == 'closed'
    return disabled + %w[closed] if meli_status == 'paused'
  end

  def upload_variations_to_ml
    p_ml = MercadoLibre::ProductVariations.new(retailer)
    p_ml.create_product_variations(self)
  end

  def earned
    earned = []
    order_items.each do |oi|
      earned << (oi.quantity * oi.unit_price)
    end
    earned.sum
  end

  def editable_attributes
    attributes = []
    editables = category.required_product_attributes
    ml_attributes.map { |atr| attributes << atr if editables.include? atr['id'] }

    attributes
  end

  def update_status_publishment(re_publish = false)
    return if meli_product_id.blank? || status == 'archived'

    return unless (available_quantity.zero? && meli_status == 'active') ||
                  (available_quantity.positive? && meli_status == 'closed' &&
                  re_publish)

    if available_quantity.zero?
      self.meli_status = 'closed'
      save

      set_ml_products.push_change_status(self.reload)
    else
      self.meli_status = 'active'
      save

      set_ml_product_publish.re_publish_product(self)
    end
  end

  def update_variations_quantities
    return unless product_variations.present?

    total_available = 0
    total_sold = 0
    product_variations.each do |pv|
      total_available += pv.data['available_quantity'].to_i
      total_sold += pv.data['sold_quantity'].to_i
    end

    update(available_quantity: total_available, sold_quantity: total_sold)
  end

  private

    def images_count
      errors.add(:base, 'Máximo de imagenes: 10') if images.count > 10
    end

    def create_variations(variations)
      variations.each do |var|
        product_variations.create(data: var)
      end
    end

    def update_variations(variations)
      variations.each do |var|
        if var['id'].present? && var['id'] != 'undefined'
          product_variations.find_by(variation_meli_id: var['id']).update(data: var)
        elsif var['variation_id'].present? && var['variation_id'] != 'undefined'
          product_variations.find(var['variation_id']).update(data: var)
        else
          product_variations.create(data: var)
        end
      end
    end

    def ml_status
      errors.add(:base, 'Sólo puede seleccionar los status active, paused y closed') if
        %w[payment_required under_review inactive].include? meli_status

      errors.add(:base, 'Del status paused sólo puede pasar a active') if
        meli_status == 'closed' && meli_status_was == 'paused'

      errors.add(:base, 'Del status closed sólo puede pasar a active') if
        meli_status == 'paused' && meli_status_was == 'closed'
    end

    def set_ml_products
      @p_ml ||= MercadoLibre::Products.new(retailer)
    end

    def set_ml_product_publish
      @publish_ml ||= MercadoLibre::ProductPublish.new(retailer)
    end
end
