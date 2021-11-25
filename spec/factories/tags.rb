FactoryBot.define do
  factory :tag do
    retailer
    tag { Faker::Lorem.word }
    tag_color { "#ffffff00" }
    font_color { "#B2B3BD" }
  end
end
