FactoryBot.define do
  factory :chat_bot_option do
    chat_bot
    text { Faker::Lorem.sentence }
    ancestry { nil }
    position { nil }
    answer { Faker::Lorem.sentence }
    option_deleted { false }

    trait :deleted do
      option_deleted { true }
    end
  end
end
