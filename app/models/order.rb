class Order < ApplicationRecord
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
  belongs_to :customer

  enum status: %i[pending completed failed]

  def total
    total = order_items.map do |order_item|
      order_item.unit_price * order_item.quantity
    end
    total.sum
  end
end
