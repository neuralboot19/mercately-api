FactoryBot.define do
  factory :retailer_user do
    retailer
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    password { 'Password1234' }
    password_confirmation { 'Password1234' }
    agree_terms { true }
  end
end
