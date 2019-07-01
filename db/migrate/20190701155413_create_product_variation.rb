class CreateProductVariation < ActiveRecord::Migration[5.2]
  def change
    create_table :product_variations do |t|
      t.references :product
      t.bigint :variation_meli_id
      t.jsonb :data, default: {}

      t.timestamps
    end
  end
end
