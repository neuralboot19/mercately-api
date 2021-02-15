FactoryBot.define do
  factory :whatsapp_template do
    status { :active }
    retailer

    trait :with_formatting_asterisks do
      text { 'This is a \*test\* with formatting asterisks' }
    end

    trait :without_formatting_asterisks do
      text { 'This is a * without * formatting asterisks' }
    end

    trait :with_text do
      text { 'Hi *. Welcome to our WhatsApp. We will be here for any question.' }
    end

    trait :with_gs_id do
      gupshup_template_id { '997dd550-c8d8-4bf7-ad98-a5ac4844a1ed' }
    end
  end
end
