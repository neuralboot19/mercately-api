class Category < ApplicationRecord
  has_ancestry
  has_many :products

  validates :meli_id, uniqueness: true
  validates :name, presence: true

  enum status: %w[active inactive]

  def required_product_attributes
    template.map do |temp|
      temp['id'] if temp['tags']['allow_variations'].blank? &&
                    (temp['tags']['catalog_required'] ||
                    temp['tags']['required']) && check_not_used_attr(temp)
    end.compact
  end

  def clean_template_variations
    template.map do |temp|
      temp if (temp['tags']['allow_variations'] ||
                            temp['tags']['catalog_required'] ||
                            temp['tags']['required']) && check_not_used_attr(temp)
    end.compact
  end

  def total_products(retailer)
    products.where(retailer_id: retailer.id).count
  end

  def total_products_sold(retailer, start_date, end_date)
    ids = products.where(retailer_id: retailer.id).ids
    OrderItem.joins(:order).where(product_id: ids, orders: { status: 'success' })
      .where('orders.created_at >= ? and orders.created_at <= ?', start_date.to_datetime, end_date.to_datetime)
      .sum(&:quantity)
  end

  def earnings(retailer, start_date, end_date)
    ids = products.where(retailer_id: retailer.id).ids
    OrderItem.joins(:order).where(product_id: ids, orders: { status: 'success' })
      .where('orders.created_at >= ? and orders.created_at <= ?', start_date.to_datetime, end_date.to_datetime)
      .sum { |oi| oi.quantity * oi.unit_price }.to_f.round(2)
  end

  private

    def check_not_used_attr(temp)
      temp['tags']['hidden'].blank? &&
        temp['tags']['fixed'].blank? && temp['tags']['inferred'].blank? &&
        temp['tags']['others'].blank? && temp['tags']['read_only'].blank? &&
        temp['tags']['restricted_values'].blank?
    end
end
