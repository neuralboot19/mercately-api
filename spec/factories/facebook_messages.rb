FactoryBot.define do
  factory :facebook_message do
    facebook_retailer
    customer
    sender_uid { Faker::IDNumber.valid }
    id_client { nil }
    text { nil }
    mid { Faker::Internet.uuid }
    reply_to { nil }
    date_read { nil }
    sent_from_mercately { false }
    sent_by_retailer { false }
    file_type { nil }
    url { nil }
    file_data { nil }
    filename { nil }
  end
end
