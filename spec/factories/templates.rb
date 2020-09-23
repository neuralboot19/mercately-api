FactoryBot.define do
  factory :template do
    title { Faker::Lorem.sentence }
    answer { Faker::Lorem.sentence }
    retailer

    trait :for_messages_ml do
      enable_for_chats { true }
    end

    trait :for_questions_ml do
      enable_for_questions { true }
    end

    trait :for_messenger do
      enable_for_messenger { true }
    end

    trait :for_whatsapp do
      enable_for_whatsapp { true }
    end

    trait :with_retailer_user do
      association :retailer_user
    end

    trait :global_template do
      global { true }
    end
  end
end
