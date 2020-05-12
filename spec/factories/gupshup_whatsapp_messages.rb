FactoryBot.define do
  factory :gupshup_whatsapp_message do
    retailer
    customer
    whatsapp_message_id { "MyString" }
    gupshup_message_id { "MyString" }
    status { 1 }
    direction { 'outbound' }
    message_payload { "" }
    source { "MyString" }
    destination { "MyString" }
    channel { "MyString" }
    sent_at { "2020-04-30 16:08:51" }
    delivered_at { "2020-04-30 16:08:51" }
    read_at { "" }
    error_payload { Hash.new }

    trait :inbound do
      direction { 'inbound' }
    end

    trait :outbound do
      direction { 'outbound' }
    end
  end
end
