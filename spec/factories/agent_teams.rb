FactoryBot.define do
  factory :agent_team do
    retailer_user
    team_assignment
    max_assignments { 0 }
    assigned_amount { 0 }

    trait :activated do
      active { true }
    end

    trait :inactive do
      active { false }
    end
  end
end
