FactoryBot.define do
  factory :global_setting do
    setting_key { Faker::Name.unique.word }
    value { Faker::Name.word }
  end
end
