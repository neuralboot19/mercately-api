FactoryBot.define do
  factory :customer_related_field do
    retailer
    name { Faker::Lorem.word }
    field_type { 0 }
  end
end
