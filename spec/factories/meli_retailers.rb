FactoryBot.define do
  factory :meli_retailer do
    access_token { Faker::Internet.uuid }
    meli_user_id { '123456789' }
    refresh_token { Faker::Internet.uuid }
    retailer
    nickname { Faker::Internet.username }
    email { Faker::Internet.email }
    points { Faker::Number.digit }
    link { Faker::Internet.url }
    seller_experience { Faker::Verb.base }
    seller_reputation_level_id { Faker::Verb.base }
    transactions_canceled { Faker::Number.digit }
    transactions_completed { Faker::Number.digit }
    ratings_negative { Faker::Number.digit }
    ratings_neutral { Faker::Number.digit }
    ratings_positive { Faker::Number.digit }
    ratings_total { Faker::Number.digit }
    phone { Faker::PhoneNumber.phone_number }
    has_meli_info { true }
    meli_token_updated_at { Time.now }
    meli_info_updated_at { Time.now }
  end
end
