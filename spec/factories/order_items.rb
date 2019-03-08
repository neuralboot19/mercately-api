FactoryBot.define do
  factory :order_item do
    order
    product
    quantity { Faker::Number.number(1) }
    unit_price { Faker::Number.decimal(2) }
  end
end
