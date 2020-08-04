FactoryBot.define do
  factory :paymentez_transaction do
    status { 'success' }
    payment_date { Time.now.to_s }
    amount { rand(5.0..200.00).round(2) }
    authorization_code { Faker::Alphanumeric.alphanumeric.first(10) }
    installments { 1 }
    dev_reference { Faker::Alphanumeric.alphanumeric.first(5) }
    message { Faker::Lorem.sentence }
    carrier_code { Faker::Alphanumeric.alphanumeric.first(10) }
    pt_id { Faker::Alphanumeric.alphanumeric.first(5) }
    status_detail { 1 }
    transaction_reference { Faker::Alphanumeric.alphanumeric.first(5) }
    retailer
    payment_plan
    paymentez_credit_card
  end
end
