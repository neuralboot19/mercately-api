FactoryBot.define do
  factory :automatic_answer do
    retailer
    message { 'Anything text here' }
    status { 'active' }

    trait :welcome do
      message_type { 'new_customer' }
    end

    trait :inactive do
      message_type { 'inactive_customer' }
      interval { 12 }
    end

    trait :whatsapp do
      platform { 'whatsapp' }
    end

    trait :messenger do
      platform { 'messenger' }
    end
  end
end
