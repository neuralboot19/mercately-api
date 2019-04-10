class Product < ApplicationRecord
  belongs_to :retailer
  belongs_to :category
  has_many :order_items, dependent: :destroy
  has_many_attached :images

  validate :images_count

  after_create :upload_ml, unless: proc { |product| product.meli_product_id }

  enum buying_mode: %w[buy_it_now auction]

  def self.ml_conditions
    %w[new used not_specified]
  end

  def update_ml(p_ml)
    self.meli_site_id = p_ml['site_id']
    self.meli_start_time = p_ml['start_time']
    self.meli_stop_time = p_ml['stop_time']
    self.meli_end_time = p_ml['end_time']
    self.meli_listing_type_id = p_ml['listing_type_id']
    self.meli_expiration_time = p_ml['expiration_time']
    self.meli_permalink = p_ml['permalink']
    self.meli_product_id = p_ml['id']
    save
  end

  private

    def upload_ml
      p_ml = MercadoLibre::Products.new(retailer)
      p_ml.create(self)
    end

    def images_count
      errors.add(:base, 'Máximo de imagenes: 10') if images.count > 10
    end
end
