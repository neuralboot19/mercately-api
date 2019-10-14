FactoryBot.define do
  factory :meli_customer do
    meli_user_id { Faker::Number.number(9) }
    nickname { Faker::Internet.username }
    email { Faker::Internet.email }
    points { 1 }
    link { "http://perfil.mercadolibre.com.ec/#{nickname}" }
    transactions_canceled { 0 }
    transactions_completed { 1 }
    ratings_negative { 1 }
    ratings_neutral { 1 }
    ratings_positive { 1 }
    ratings_total { 1 }
    phone { Faker::Number.number(7) }
    phone_area { '098' }
  end
end
