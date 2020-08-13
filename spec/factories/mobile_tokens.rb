FactoryBot.define do
  factory :mobile_token do
    association :retailer_user, factory: [:retailer_user, :with_retailer]
    sequence(:token) { |n| "myAw3s0m37ok3N#{n}" }
    sequence(:mobile_push_token) { |n| "myAw3s0m3m081L37ok3N#{n}" }
    expiration { 1.week.from_now }

    trait :expired do
      expiration { Time.now - 1.hour }
    end
  end
end
