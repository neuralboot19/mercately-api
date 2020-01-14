FactoryBot.define do
  factory :customer do
    retailer
    email { Faker::Internet.email }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    full_name { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
    phone { Faker::PhoneNumber.cell_phone }
    id_type { 'ruc' }
    id_number { Faker::IDNumber.valid }
    address { Faker::Address.street_address }
    city { 'Quito' }
    state { 'Pichincha' }
    country_id { 'EC' }
    zip_code { '170207' }
    meli_customer { nil }

    trait :from_ml do
      meli_nickname { meli_customer.nickname }
      meli_customer_id { meli_customer.id }
    end
  end
end
