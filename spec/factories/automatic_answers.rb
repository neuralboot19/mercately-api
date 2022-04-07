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
      whatsapp {true}
    end

    trait :messenger do
      messenger { true }
    end

    trait :instagram do
      instagram { true }
    end
  end
end
