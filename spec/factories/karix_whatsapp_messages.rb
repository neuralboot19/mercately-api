FactoryBot.define do
  factory :karix_whatsapp_message do
    uid { Faker::IDNumber.valid }
    account_uid { Faker::IDNumber.valid }
    source { "MyString" }
    destination { "MyString" }
    country { "MyString" }
    content_type { "MyString" }
    created_time { "2020-01-17 15:16:14" }
    sent_time { "2020-01-17 15:16:14" }
    delivered_time { "2020-01-17 15:16:14" }
    updated_time { "2020-01-17 15:16:14" }
    status { "MyString" }
    direction { "MyString" }
    retailer
    customer
  end
end
