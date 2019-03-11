FactoryBot.define do
  factory :order do
    customer
    status { 'pending' }
  end
end
