FactoryBot.define do
  factory :notifications, class: 'Notification' do
    title { 'MyString' }
    body { '<p>MyText</p>' }
    visible_for { 'all' }
    visible_until { nil }
  end
end
