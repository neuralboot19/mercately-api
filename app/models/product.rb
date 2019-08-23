class Product < ApplicationRecord
  belongs_to :retailer
  belongs_to :category
  has_many :order_items, dependent: :destroy
  has_many :questions, dependent: :destroy
  has_many_attached :images
  has_many :product_variations, dependent: :destroy

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

  after_save :delete_duplicated

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

    set_active = meli_status == 'active' || status == 'active'
    p_ml = MercadoLibre::Products.new(retailer)
    p_ml.push_update(self, past_meli_status, set_active)
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

    p_ml = MercadoLibre::Products.new(retailer)
    p_ml.load_main_picture(reload, true)
  end

  def upload_ml
    return if retailer.meli_retailer.nil?

    p_ml = MercadoLibre::Products.new(retailer)
    p_ml.create(self)
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
      delete_variations(variations)
      delete_variations_by_ids(variations)
    end

    def delete_variations(variations)
      current_variations = product_variations.pluck(:variation_meli_id).compact
      variation_ids = variations.map { |vari| vari['id'].to_i }.compact

      current_variations -= variation_ids if current_variations.present?

      return unless current_variations.present?

      product_variations.where(variation_meli_id: current_variations).delete_all if
        current_variations.present?
    end

    def delete_variations_by_ids(variations)
      current_variation_ids = product_variations.pluck(:id).compact
      variation_merc_ids = variations.map { |vari| vari['variation_id'].to_i }.compact

      current_variation_ids -= variation_merc_ids if current_variation_ids.present?

      return unless current_variation_ids.present?

      product_variations.where(id: current_variation_ids).delete_all if
        current_variation_ids.present?
    end

    def ml_status
      errors.add(:base, 'Sólo puede seleccionar los status active, paused y closed') if
        %w[payment_required under_review inactive].include? meli_status

      errors.add(:base, 'Del status paused sólo puede pasar a active') if
        meli_status == 'closed' && meli_status_was == 'paused'

      errors.add(:base, 'Del status closed sólo puede pasar a active') if
        meli_status == 'paused' && meli_status_was == 'closed'
    end

    def delete_duplicated
      return unless meli_product_id.present?

      delete_product = Product.find_by(meli_product_id: parent_meli_id) if
        parent_meli_id.present?

      delete_product.destroy if delete_product.present?

      delete_own_product = Product.find_by(parent_meli_id: meli_product_id)

      self.destroy if delete_own_product.present?
    end
end
