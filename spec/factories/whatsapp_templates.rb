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
  end
end
