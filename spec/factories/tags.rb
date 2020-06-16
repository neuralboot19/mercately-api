FactoryBot.define do
  factory :tag do
    retailer
    tag { Faker::Lorem.word }
  end
end
