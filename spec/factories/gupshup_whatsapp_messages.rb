FactoryBot.define do
  factory :gupshup_whatsapp_message do
    retailer
    customer
    whatsapp_message_id { "MyString" }
    gupshup_message_id { "MyString" }
    status { 1 }
    direction { 'outbound' }
    message_payload {
      {
         'app': 'MercatelyTest',
         'timestamp': 1589254706428,
         'version': 2,
         'type': 'message',
         'payload': {
            'id': 'R4ND0m1D',
            'source': '5934747474333',
            'type': 'text',
            'payload': {
               'text': 'Hola TEST'
            },
            'sender': {
               'phone': '593999999999',
               'name': 'bj',
               'country_code': '593',
               'dial_code': '999999999'
            }
         }
      }
    }
    source { "MyString" }
    destination { "MyString" }
    channel { "MyString" }
    sent_at { "2020-04-30 16:08:51" }
    delivered_at { "2020-04-30 16:08:51" }
    read_at { "" }
    error_payload { nil }
    message_type { 'notification' }

    trait :inbound do
      direction { 'inbound' }
    end

    trait :outbound do
      direction { 'outbound' }
    end

    trait :notification do
      message_payload { { 'isHSM': 'true' } }
      message_type { 'notification' }
    end

    trait :conversation do
      message_payload { { 'isHSM': 'false' } }
      message_type { 'conversation' }
    end
  end
end
