FactoryBot.define do
  factory :agent_notification do
    retailer_user
    customer

    trait :whatsapp do
      notification_type { 'whatsapp' }
    end

    trait :messenger do
      notification_type { 'messenger' }
    end
  end
end
