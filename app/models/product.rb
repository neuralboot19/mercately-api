class Product < ApplicationRecord
  belongs_to :retailer
  has_many :order_items, dependent: :destroy
  has_many_attached :images

  after_create :upload_ml, unless: Proc.new { |product| product.meli_product_id }

  def ml_condition
    %w[new used not_specified]
  end

  def update_ml(ml)
    self.meli_site_id = ml['site_id']
    self.meli_start_time = ml['start_time']
    self.meli_stop_time = ml['stop_time']
    self.meli_end_time = ml['end_time']
    self.meli_listing_type_id = ml['listing_type_id']
    self.meli_expiration_time = ml['expiration_time']
    self.meli_permalink = ml['permalink']
    self.meli_product_id = ml['id']
    self.save
  end

  private
    def upload_ml
      ml = MercadoLibre::Products.new(self.retailer)
      ml.create(self)
    end
end
