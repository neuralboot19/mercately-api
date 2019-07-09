class Product < ApplicationRecord
  belongs_to :retailer
  belongs_to :category
  has_many :order_items, dependent: :destroy
  has_many :questions, dependent: :destroy
  has_many_attached :images
  has_many :product_variations, dependent: :destroy

  validate :images_count
  validates :meli_product_id, uniqueness: true, allow_nil: true

  after_create :upload_ml, if: proc { !retailer.meli_retailer.nil? }
  after_update :update_ml_info, if: proc { |product| product.meli_product_id }

  enum buying_mode: %w[buy_it_now auction]
  enum condition: %w[new_product used not_specified]

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
    save
  end

  def attach_image(url, filename)
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
    File.delete('./public/upload-' + filename + '.jpg')
  end

  def upload_variations_to_ml
    p_ml = MercadoLibre::ProductVariations.new(retailer)
    p_ml.create_product_variations(self)
  end

  private

    def update_ml_info
      p_ml = MercadoLibre::Products.new(retailer)
      p_ml.push_update(self)
    end

    def upload_ml
      p_ml = MercadoLibre::Products.new(retailer)
      p_ml.create(self)
    end

    def images_count
      errors.add(:base, 'Máximo de imagenes: 10') if images.count > 10
    end
end
