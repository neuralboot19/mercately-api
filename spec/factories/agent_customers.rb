FactoryBot.define do
  factory :agent_customer do
    retailer_user { retailer_user }
    customer { customer }
  end
end
