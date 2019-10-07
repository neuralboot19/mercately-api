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

    trait :with_meli_retailer do
      meli_retailer { MeliRetailer.new(access_token: Faker::Internet.uuid) }
    end
  end
end
