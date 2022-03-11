FactoryBot.define do
  factory :retailer do
    name { Faker::Company.name }
    id_number { Faker::IDNumber.spanish_citizen_number }
    id_type { Retailer.id_types.keys.sample }
    address { Faker::Address.street_address }
    city { Faker::Address.city }
    state { Faker::Address.state }
    zip_code { Faker::Address.zip_code.first(5) }
    phone_number { Faker::PhoneNumber.cell_phone_with_country_code }
    phone_verified { true }
    ws_balance { 5 }
    ws_next_notification_balance { 1.5 }
    ws_notification_cost { 0.0672 }
    ws_conversation_cost { 0.0 }
    unlimited_account { false }
    hs_expires_in { 6.hours.from_now }
    max_agents { 10 }
    currency { 'USD' }

    trait :with_retailer_user do
      association :retailer_user
    end

    trait :with_admin do
      association :retailer_user, factory: [:retailer_user, :admin]
    end

    trait :whatsapp_enabled do
      whats_app_enabled { true }
    end

    trait :karix_integrated do
      whats_app_enabled { true }
      karix_whatsapp_phone { Faker::PhoneNumber.cell_phone_with_country_code }
      karix_account_uid { 'MyAccountUid' }
      karix_account_token { 'MyAccountToken' }
    end

    trait :gupshup_integrated do
      whats_app_enabled { true }
      gupshup_src_name { 'MySrCName' }
      gupshup_phone_number { Faker::PhoneNumber.cell_phone_with_country_code }
    end

    trait :with_chat_bots do
      allow_bots { true }
    end

    trait :with_stats do
      show_stats { true }
    end
  end
end
