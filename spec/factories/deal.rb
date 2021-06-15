FactoryBot.define do
  factory :deal do
    name { 'Negociacion con Henry' }
    amount { 1000.00 }
    funnel_step
    retailer
  end
end
