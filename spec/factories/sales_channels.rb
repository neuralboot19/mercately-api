FactoryBot.define do
  factory :sales_channel do
    retailer
    title { Faker::Lorem.word }
    channel_type { 'other' }

    trait :mercado_libre do
      channel_type { 'mercadolibre' }
    end

    trait :messenger do
      channel_type { 'messenger' }
    end

    trait :whatsapp do
      channel_type { 'whatsapp' }
    end
  end
end
