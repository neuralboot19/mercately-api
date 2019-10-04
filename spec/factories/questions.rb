FactoryBot.define do
  factory :question do
    product
    answer { Faker::Lorem.sentence }
    question { Faker::Lorem.question }
    meli_id { '-f0399ff02c324f3f9780f1bd2219460e-' }
    customer
  end
end
