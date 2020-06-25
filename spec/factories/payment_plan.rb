FactoryBot.define do
  factory :payment_plan do
    retailer
    price { 20.0 }
    start_date { nil }
    next_pay_date { nil }
    status { 0 }
    plan { 0 }
    karix_available_messages { 100 }
    karix_available_notifications { 100 }
  end
end
