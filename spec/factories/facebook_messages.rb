FactoryBot.define do
  factory :facebook_message do
    facebook_retailer
    customer
    sender_uid { Faker::IDNumber.valid }
    id_client { Faker::IDNumber.valid }
    text { Faker::Lorem.paragraph }
    mid { Faker::Internet.uuid }
    reply_to { nil }
    date_read { nil }
    sent_from_mercately { false }
    sent_by_retailer { false }
    file_type { nil }
    url { nil }
    file_data { nil }
    filename { nil }

    trait :inbound do
      sent_by_retailer { false }
    end

    trait :outbound do
      sent_by_retailer { true }
    end
  end
end
