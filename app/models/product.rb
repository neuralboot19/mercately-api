# frozen_string_literal: true

class Product < ApplicationRecord
  include ProductModelConcern
  include WebIdGenerateableConcern

  paginates_per 50

  belongs_to :retailer
  belongs_to :category, optional: true
  has_many :order_items
  has_many :orders, through: :order_items
  has_many :questions
  has_many :product_variations
  has_many_attached :images

  validates :title, presence: true
  validates :price, presence: true
  validates :code, uniqueness: { scope: :retailer_id, message: 'Código ya está en uso.' }, allow_blank: true
  validates_format_of :url, with: /\A(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?\z/x, allow_blank: true
  validate :check_variations
  validate :check_images
  validate :check_main_image
  # validate :url_format

  before_update :assign_main_picture
  before_save :nullify_code
  after_create :generate_web_id
  # after_save :update_facebook_inventory, if: :saved_change_to_available_quantity?

  enum buying_mode: %i[buy_it_now classified]
  enum condition: %i[new_product used not_specified]
  enum status: %i[active archived], _prefix: true
  enum meli_status: %i[active payment_required paused closed under_review inactive]
  enum from: %i[mercately mercadolibre], _prefix: true

  attr_accessor :upload_product, :incoming_images, :incoming_variations, :deleted_images, :main_image,
                :changed_main_image, :parent_product, :upload_to_facebook, :avoid_update_inventory

  ransacker :sort_by_earned do
    Arel.sql('coalesce((select sum(quantity * unit_price) as total from order_items, orders where ' \
      'orders.id = order_items.order_id and orders.status = 1 and ' \
      'order_items.product_id = products.id), 0)')
  end

  ransacker :sort_by_order_items_count do
    Arel.sql('coalesce((select count(distinct(order_items.id)) as total from order_items, orders where ' \
      'orders.id = order_items.order_id and orders.status = 1 and ' \
      'order_items.product_id = products.id), 0)')
  end

  def self.default_scope
    where(Product.arel_table[:created_at].lt(DateTime.new(2021, 4, 29)))
      .or(from_mercately.where(Product.arel_table[:created_at].gt(DateTime.new(2021, 4, 29))))
  end

  def attach_image(url, filename, index = -1)
    img = ActiveStorage::Blob.joins(:attachments)
      .where(filename: filename, active_storage_attachments:
      {
        name: 'images',
        record_type: 'Product',
        record_id: id
      }).first

    return if check_cloudinary_image(img)

    begin
      tempfile = MiniMagick::Image.open(url)
      tempfile.resize '500x500'
    rescue
      return
    end

    images.attach(io: File.open(tempfile.path), filename: filename)
    update(main_picture_id: images.last.id) if index.zero?
  end

  def update_ml_info(past_meli_status)
    return unless meli_product_id.present?

    set_active = (meli_status == 'active' || status == 'active') && available_quantity.positive?
    set_ml_products.push_update(self, past_meli_status, set_active)
  end

  def update_main_picture
    return unless main_image

    images.attach(io: File.open(main_image.tempfile), filename: main_image.original_filename || 'main_image.png')

    update(main_picture_id: images.last.id)
    set_ml_products.load_main_picture(reload, true) if able_to_send_to_ml?
  end

  def upload_ml
    return unless upload_product == true

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
    # upload_variations_to_ml if able_to_send_to_ml?
  end

  def delete_images(delete_images, variations, past_meli_status)
    ids = []
    delete_images.each do |img|
      ids << img[1]
    end

    ids.delete('')
    images.where(id: ids).purge

    return if variations.present? || ids.blank?

    reload
    update_ml_info(past_meli_status)
  end

  # TODO: Make private
  def upload_variations_to_ml
    p_ml = MercadoLibre::ProductVariations.new(retailer)
    p_ml.create_product_variations(self)
  end

  def earned
    order_items.includes(:order).where(orders: { status: 'success' })
      .sum('order_items.quantity * order_items.unit_price')
  end

  # TODO: move to service (or controller (?))
  def editable_attributes
    attributes = []
    editables = category.required_product_attributes
    ml_attributes.map { |atr| attributes << atr if editables.include? atr['id'] }

    attributes
  end

  # TODO: move to service
  def update_status_publishment(re_publish = false)
    return if meli_product_id.blank? || status == 'archived'

    if change_status_publishment?
      update_meli_status_and_save('closed')

      set_ml_products.push_change_status(reload)
    elsif go_re_publish? && re_publish
      update_meli_status_and_save('active')

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

  def include_before_bids_info?
    !orders
      .where('meli_order_id IS NOT NULL AND feedback_message IS NOT NULL')
      .where(feedback_reason: nil, status: 2).exists?
  end

  # Chequea si el producto tiene imagenes o no
  def product_without_images?
    if images.blank?
      errors.add(:base, 'Debe agregar entre 1 y 10 imágenes.')
      return true
    end

    false
  end

  def upload_facebook
    return unless retailer.facebook_catalog&.connected? && upload_to_facebook == true

    set_facebook_products.create(self)
  end

  def update_facebook_product
    return unless facebook_product_id.present? || connected_to_facebook == true || upload_to_facebook == true

    if available_quantity.positive?
      set_facebook_products.update_or_upload(self)
    elsif facebook_product_id.present?
      set_facebook_products.delete(self)
    end
  end

  def to_param
    web_id
  end

  private

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

    def update_meli_status_and_save(status)
      self.meli_status = status
      save
    end

    def change_status_publishment?
      (available_quantity.zero? || available_quantity.negative?) && meli_status == 'active'
    end

    def go_re_publish?
      available_quantity.positive? && meli_status == 'closed'
    end

    # Chequea las variaciones previo al guardado del producto
    def check_variations
      return unless from_mercately?

      errors.add(:base, 'Debe agregar al menos una variación.') if
        check_for_variations? && incoming_variations.blank? && product_variations.blank?
    end

    # Chequea las imagenes previo al guardado del producto
    def check_images
      errors.add(:base, 'Debe agregar entre 1 y 10 imágenes.') if mandatory_images?
    end

    # Chequea si la imagen principal del producto esta presente
    def check_main_image
      errors.add(:base, 'Debe agregar una foto principal') if main_image_present?
    end

    def url_format
      return unless facebook_product_id.present? || connected_to_facebook == true || upload_to_facebook == true

      errors.add(:base, 'Debe agregar una URL válida') unless
        url =~ /^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]
          {1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/x
    end

    def update_facebook_inventory
      return if avoid_update_inventory == true || facebook_product_id.blank?

      if available_quantity.positive?
        set_facebook_products.update_inventory(self)
      else
        set_facebook_products.delete(self)
      end
    end

    def set_ml_products
      @set_ml_products ||= MercadoLibre::Products.new(retailer)
    end

    def set_ml_product_publish
      @set_ml_product_publish ||= MercadoLibre::ProductPublish.new(retailer)
    end

    def set_facebook_products
      @set_facebook_products ||= Facebook::Products.new(retailer)
    end
end
