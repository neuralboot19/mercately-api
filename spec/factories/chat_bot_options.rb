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

    trait :with_image_file do
      file { fixture_file_upload 'spec/fixtures/profile.jpg', 'image/jpeg' }
    end

    trait :with_pdf_file do
      file { fixture_file_upload 'spec/fixtures/dummy.pdf', 'application/pdf' }
    end
  end
end
