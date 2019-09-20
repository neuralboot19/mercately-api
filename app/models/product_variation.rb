class ProductVariation < ApplicationRecord
  default_scope -> { where('product_variations.status = 0') }

  belongs_to :product
  has_many :order_items
  validates :variation_meli_id, uniqueness: true, allow_nil: true

  enum status: %w[active inactive]

  def update_data(ml_data)
    variation_ids = ml_data['variations'].map { |var| var['id'] }.compact
    current_variation_ids = product.product_variations.pluck(:variation_meli_id).compact
    variation_ids -= current_variation_ids

    if variation_ids.present?
      self.variation_meli_id = variation_ids[0]
      info = ml_data['variations'].select { |var| var['id'] == variation_ids[0] }
    else
      info = ml_data['variations'].select { |var| var['id'] == variation_meli_id }
    end

    if info.present?
      info[0]['sold_quantity'] = data['sold_quantity']
      self.data = info[0].except('catalog_product_id')
    end

    save
  end
end
