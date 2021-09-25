FactoryBot.define do
  factory :whatsapp_log do
    retailer
    payload_sent { '' }
    response { '' }
    gupshup_whatsapp_message { nil }
  end
end
