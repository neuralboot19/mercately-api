FactoryBot.define do
  factory :hubspot_field do
    sequence(:hubspot_field) { |n| "hubspot_field_#{n}" }
    sequence(:hubspot_label) { |n| "hubspot_label_#{n}" }
    hubspot_type { 'string' }
    taken { false }
    deleted { false }

    trait :with_retailer do
      association :retailer
    end
  end
end
