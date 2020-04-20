FactoryBot.define do
  factory :retailer_user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    password { 'Password1234' }
    password_confirmation { 'Password1234' }
    agree_terms { true }

    trait :with_retailer do
      association :retailer
    end
    trait :admin do
      retailer_admin { true }
    end

    trait :agent do
      retailer_admin { false }
    end
  end
end
