FactoryBot.define do
  factory :message do
    customer
    order
    question { Faker::Lorem.question }
    answer { nil }
    date_read { nil }
    meli_question_type { 'from_product' }
    meli_id { Faker::Number.number(9) }

    trait :from_retailer do
      question { nil }
      answer { Faker::Lorem.paragraph }
      date_read { Time.now }
    end

    trait :readed do
      date_read { Time.now }
    end
  end
end
