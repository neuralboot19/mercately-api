FactoryBot.define do
  factory :order do
    customer
    status { 'pending' }
    currency_id { 'usd' }

    trait :completed do
      status { 'success' }
      feedback_rating { 'positive' }
      feedback_message { Faker::Lorem.paragraph }
    end

    trait :cancelled do
      status { 'cancelled' }
      feedback_reason { Order.feedback_reasons.keys.sample }
      feedback_rating { 'neutral' }
      feedback_message { Faker::Lorem.paragraph }
    end

    trait :from_ml do
      meli_order_id { Faker::Number.number(9) }
    end
  end
end
