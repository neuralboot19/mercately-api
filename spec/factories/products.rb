FactoryBot.define do
  factory :product do
    retailer
    category
    title { Faker::Superhero.name }
    price { Faker::Number.decimal(2) }
    available_quantity { Faker::Number.number(2) }
    buying_mode { 'buy_it_now' }
    condition { Product.conditions.keys.sample }
    description { Faker::Lorem.paragraph }
    sold_quantity { 0 }
    code { nil }

    trait :from_ml do
      meli_product_id { "MEC#{Faker::Number.number(9)}" }
      meli_status { 'active' }
      meli_listing_type_id { 'free' }
      ml_attributes do
        '[{
          "value_name": "Marfil",
          "name": "Marca",
          "value_struct": null,
          "attribute_group_name": "Otros",
          "attribute_group_id": "OTHERS",
          "value_id": null,
          "id": "BRAND"
        },{
          "value_name": "No",
          "name": "Incluye asiento",
          "value_struct": null,
          "attribute_group_name": "Otros",
          "attribute_group_id": "OTHERS",
          "value_id": "242084",
          "id": "INCLUDES_SEAT"
        },{
          "value_name": "No",
          "name": "Es inflamable",
          "value_struct": null,
          "attribute_group_name": "Otros",
          "attribute_group_id": "OTHERS",
          "value_id": "242084",
          "id": "IS_FLAMMABLE"
        },{
          "value_name": "No",
          "name": "Es kit",
          "value_struct": null,
          "attribute_group_name": "Otros",
          "attribute_group_id": "OTHERS",
          "value_id": "242084",
          "id": "IS_KIT"
        },{
          "value_name": "Nuevo",
          "name": "Condición del ítem",
          "value_struct": null,
          "attribute_group_name": "Otros",
          "attribute_group_id": "OTHERS",
          "value_id": "2230284",
          "id": "ITEM_CONDITION"
        },{
          "value_name": "Grande",
          "name": "Modelo",
          "value_struct": null,
          "attribute_group_name": "Otros",
          "attribute_group_id": "OTHERS",
          "value_id": null,
          "id": "MODEL"
        }]'
      end
    end
  end
end
