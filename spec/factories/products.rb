FactoryBot.define do
  factory :product do
    retailer
    category
    title { Faker::Superhero.name }
    price { Faker::Number.number(2) }
    available_quantity { Faker::Number.number(2) }
    buying_mode { Product.buying_modes.first[0] }
    condition { Product.conditions.first[0] }
    description { Faker::Lorem.paragraphs }
  end
end
