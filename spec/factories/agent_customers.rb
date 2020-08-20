FactoryBot.define do
  factory :agent_customer do
    retailer_user
    customer
    team_assignment { nil }
  end
end
