FactoryBot.define do
  factory :facebook_catalog do
    retailer
    uid { Faker::Internet.uuid }
    name { Faker::Name.first_name }
    business_id { Faker::Internet.uuid }
  end
end
