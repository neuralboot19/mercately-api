FactoryBot.define do
  factory :meli_retailer do
    retailer
    access_token { 'APP_USR-4500872344400148-112218-1b799eeac1820d4c50ebc88fbd488cd3-425933549' }
    refresh_token { Faker::Internet.uuid }
    nickname { Faker::Internet.username }
    email { Faker::Internet.email }
    points { [1..5].sample }
    link { "https://www.mercadolibre.com.ec/#{nickname}" }
    seller_experience { [1..5].sample }
    seller_reputation_level_id { nil }
    transactions_canceled { [1..5].sample }
    transactions_completed { [1..5].sample }
    ratings_negative { [1..5].sample }
    ratings_neutral { [1..5].sample }
    ratings_positive { [1..5].sample }
    ratings_total { [1..5].sample }
    phone { Faker::PhoneNumber.phone_number }
    has_meli_info { true }
    meli_user_id { 425_933_549 }
    meli_token_updated_at { Time.now }
    meli_info_updated_at { Time.now }
    created_at { Time.now }
  end
end
