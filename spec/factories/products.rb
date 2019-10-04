FactoryBot.define do
  factory :product do
    retailer
    title { Faker::Superhero.name }
    category
    price { Faker::Number.number(2) }
    available_quantity { Faker::Number.number(2) }
    buying_mode { Product.buying_modes.first[0] }
    condition { Product.conditions.first[0] }
    description { Faker::Lorem.paragraphs }
  end
end
