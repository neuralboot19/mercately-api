FactoryBot.define do
  password = Faker::Internet.password

  factory :retailer_user do
    retailer
    email { Faker::Internet.email }
    password { password }
    password_confirmation { password }
    agree_terms { true }
  end
end
