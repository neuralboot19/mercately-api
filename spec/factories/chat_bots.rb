FactoryBot.define do
  factory :chat_bot do
    retailer
    name { Faker::Lorem.word }
    trigger { Faker::Lorem.word }
    failed_attempts { 0 }
    goodbye_message { Faker::Lorem.sentence }
    any_interaction { false }
    enabled { false }

    trait :with_any_interaction do
      any_interaction { true }
    end

    trait :bot_enabled do
      enabled { true }
    end

    trait :with_accented_trigger do
      trigger { 'Hóla TÉST' }
    end
  end
end
