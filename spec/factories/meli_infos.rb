FactoryBot.define do
  factory :meli_info do
    access_token { 'MyString' }
    meli_user_id { 'MyString' }
    refresh_token { 'MyString' }
    retailer { nil }
  end
end
