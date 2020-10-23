FactoryBot.define do
  factory :customer_hubspot_field do
    retailer
    hubspot_field
    customer_field { 'email' }
  end
end
