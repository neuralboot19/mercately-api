FactoryBot.define do
  factory :category do
    name { Faker::Lorem.word }
    meli_id { '-MEC189402-' }
  end
end
