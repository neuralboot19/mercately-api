class ProductVariation < ApplicationRecord
  default_scope -> { active }

  belongs_to :product
  has_many :order_items

  enum status: %w[active inactive]

  scope :all_variations, -> (product_id) { unscope(:where).where(product_id: product_id) }

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
