FactoryBot.define do
  factory :chat_history do
    retailer_user
    customer
    chat_status { nil }
    created_at { nil }
  end
end