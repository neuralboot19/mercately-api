FactoryBot.define do
  factory :order_item do
    order
    product
    product_variation { nil }
    quantity { Faker::Number.number(1) }
    unit_price { Faker::Number.decimal(2) }
    from_ml { false }
  end
end
