FactoryBot.define do
  factory :paymentez_credit_card do
    card_type { 'vi' }
    number { rand(1000..9999).to_s }
    name { Faker::Name.name }
    retailer
    token { Faker::Alphanumeric.alphanumeric.first(10) }
    status { 'success' }
    expiry_month { rand(1..12).to_s }
    expiry_year { rand(Date.today.year..(Date.today.year + 5)) }
    deleted { false }
    main { false }

    trait :main_card do
      main { true }
    end
  end
end
