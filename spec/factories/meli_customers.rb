FactoryBot.define do
  factory :meli_customer do
    access_token { "MyString" }
    meli_user_id { "MyString" }
    refresh_token { "MyString" }
    nickname { "MyString" }
    email { "MyString" }
    points { 1 }
    link { "MyString" }
    seller_experience { "MyString" }
    seller_reputation_level_id { "MyString" }
    transactions_canceled { 1 }
    transactions_completed { 1 }
    ratings_negative { 1 }
    ratings_neutral { 1 }
    ratings_positive { 1 }
    ratings_total { 1 }
    customer { nil }
    phone { "MyString" }
  end
end
