FactoryBot.define do
  factory :team_assignment do
    retailer
    name { Faker::Lorem.word }
    active_assignment { true }

    trait :assigned_default do
      default_assignment { true }
    end
  end
end
