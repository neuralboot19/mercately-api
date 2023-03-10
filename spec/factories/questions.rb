FactoryBot.define do
  factory :question do
    product
    customer
    question { Faker::Lorem.question }
    answer { nil }
    date_read { nil }
    status { 'UNANSWERED' }
    answer_status { 'ACTIVE' }
    meli_question_type { 'from_product' }
    meli_id { Faker::Number.number(9) }

    trait :answered do
      answer { Faker::Lorem.paragraph }
      status { 'ANSWERED' }
    end

    trait :from_order do
      meli_question_type { 'from_order' }
    end

    trait :readed do
      date_read { Time.now }
    end
  end
end
