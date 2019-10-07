FactoryBot.define do
  factory :product do
    retailer
    category
    title { Faker::Superhero.name }
    price { Faker::Number.decimal(2) }
    available_quantity { Faker::Number.number(2) }
    buying_mode { 'buy_it_now' }
    condition { Product.conditions.keys.sample }
    description { Faker::Lorem.paragraph }
  end
end
