FactoryBot.define do
  factory :template do
    title { Faker::Lorem.sentence }
    answer { Faker::Lorem.sentence }
    retailer
  end
end
