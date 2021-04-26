FactoryBot.define do
  factory :contact_group do
    association :retailer, factory: [:retailer, :gupshup_integrated, :with_admin]

    sequence :name do |n|
      "Grupo #{n}"
    end

    trait :with_customers do
      customers { build_list(:customer, 3, retailer: retailer) }
    end
  end
end
