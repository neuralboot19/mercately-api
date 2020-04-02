FactoryBot.define do
  factory :retailer do
    name { Faker::Company.name }
    id_number { Faker::IDNumber.spanish_citizen_number }
    id_type { Retailer.id_types.keys.sample }
    address { Faker::Address.street_address }
    city { Faker::Address.city }
    state { Faker::Address.state }
    zip_code { Faker::Address.zip_code.first(5) }
    phone_number { Faker::PhoneNumber.cell_phone_with_country_code }
    phone_verified { true }

    trait :with_retailer_user do
      association :retailer_user
    end

    trait :whatsapp_enabled do
      whats_app_enabled { true }
    end
  end
end
