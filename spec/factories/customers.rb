FactoryBot.define do
  factory :customer do
    retailer
    email { Faker::Internet.email }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    phone { Faker::PhoneNumber.cell_phone }
    id_type { 'ruc' }
    id_number { Faker::IDNumber.valid }
    address { Faker::Address.street_address }
    city { 'Quito' }
    state { 'Pichincha' }
    country_id { 'EC' }
    zip_code { '170207' }
    meli_customer { nil }
    unread_messenger_chat { false }

    trait :from_ml do
      meli_nickname { meli_customer.nickname }
      meli_customer_id { meli_customer.id }
    end

    trait :from_fb do
      psid { rand(10000..20000) }
    end

    trait :with_retailer_karix_integrated do
      association :retailer, factory: [:retailer, :karix_integrated]
    end

    trait :with_retailer_gupshup_integrated do
      association :retailer, factory: [:retailer, :gupshup_integrated]
    end

    trait :able_to_start_bots do
      allow_start_bots {true}
    end

    trait :opted_in do
      whatsapp_opt_in { true }
    end
  end
end
