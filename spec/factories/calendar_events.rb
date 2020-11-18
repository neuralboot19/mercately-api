FactoryBot.define do
  factory :calendar_event do
    retailer
    title { "MyString" }
    starts_at { Time.now }
    ends_at { Time.now + 10.minutes }
    remember { 10 }
    timezone { '-0400' }

    after :build do |i|
      i.retailer_user = create(:retailer_user, retailer: i.retailer)
    end
  end
end
