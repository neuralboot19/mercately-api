FactoryBot.define do
  factory :meli_retailer do
    access_token {}
    meli_user_id {}
    refresh_token {}
    retailer_id {}
    nickname {}
    email {}
    points {}
    link {}
    seller_experience {}
    seller_reputation_level_id {}
    transactions_canceled {}
    transactions_completed {}
    ratings_negative {}
    ratings_neutral {}
    ratings_positive {}
    ratings_total {}
    customer_id {}
    phone {}
    has_meli_info {}
    meli_token_updated_at {}
    meli_info_updated_at {}
  end
end
