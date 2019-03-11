FactoryBot.define do
  factory :product do
    retailer
    title { Faker::Superhero.name }
    category_id { 'MyString' }
    price { Faker::Number.decimal(2) }
    available_quantity { Faker::Number.number(2) }
    buying_mode { 'buy_it_now' }
    condition { Product.ml_condition.sample }
    description { Faker::Lorem.paragraphs }
  end
end
