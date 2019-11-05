FactoryBot.define do
  factory :product_variation do
    product
    status { 'active' }
    variation_meli_id { nil }
    data do
      {
        'attribute_combinations': [
          {
            'id': 'COLOR',
            'value_name': 'Negro'
          }
        ],
        'price': 50.5,
        'available_quantity': 5,
        'sold_quantity': 1,
        'picture_ids': []
      }
    end

    trait :from_ml do
      variation_meli_id { Faker::Number.number(11) }
    end
  end
end
