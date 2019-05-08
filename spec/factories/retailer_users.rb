FactoryBot.define do
  factory :retailer_user do
    retailer
    email { Faker::Internet.email }
    password { 'Password1234' }
    password_confirmation { 'Password1234' }
    agree_terms { true }
  end
end
