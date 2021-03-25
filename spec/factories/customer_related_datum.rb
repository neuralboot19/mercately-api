FactoryBot.define do
  factory :customer_related_datum do
    customer_related_field
    customer
    data { Faker::Lorem.word }
  end
end
