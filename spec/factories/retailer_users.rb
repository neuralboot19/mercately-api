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
      retailer_supervisor { false }
      retailer_admin { true }
    end

    trait :supervisor do
      retailer_admin { false }
      retailer_supervisor { true }
    end

    trait :agent do
      retailer_supervisor { false }
      retailer_admin { false }
    end

    trait :from_fb do
      uid { Faker::IDNumber.valid }
      provider { 'facebook' }
      facebook_access_token { 'EAACx6JZCO4HYBAKlbKurdBSYxgrnaZAbsxZCwA7CM8YUY8a28wD3ag5nxWfOELceZBHbZCbvuq2n5ZAs0aVA4TEAF7SwCUujvrfs1KI2VaLzruW91MCZCyXjPLuz2osZAZBPBApryz2LRVWC0DMYZCDLGrZAo9IkuhKHnBanzooxd6mrgZDZD' }
    end
  end
end
