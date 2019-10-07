require 'rails_helper'

RSpec.describe ProductVariation, type: :model do
  let(:variations) { {
    'variations': [ {
      'id': 12345678910,
      'attribute_combinations': [
        {
          'id': 'COLOR',
          'name': 'Color',
          'value_id': '52049',
          'value_name': 'Negro'
        }
      ],
      'price': 50.5,
      'available_quantity': 5,
      'sold_quantity': 0,
      'picture_ids': [
        '553111-MLA20482692355_112015'
      ],
      'seller_custom_field': nil,
      'catalog_product_id': nil
      }]
    }.with_indifferent_access
  }

  subject(:product_variation) { build(:product_variation) }

  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(%w[active inactive]) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:product) }
    it { is_expected.to have_many(:order_items) }
  end

  describe '#update_data' do
    context 'when response is returned from ML after upload variations' do
      it 'assigns the variation_meli_id to product_variation' do
        product_variation.save
        expect(product_variation.variation_meli_id).to be_nil
        product_variation.update_data(variations)
        expect(product_variation.variation_meli_id).to eq(variations['variations'][0]['id'])
      end

      it 'adds the picture_ids to product_variation data attribute' do
        product_variation.save
        expect(product_variation.data['picture_ids']).to be_empty
        product_variation.update_data(variations)
        expect(product_variation.data['picture_ids']).not_to be_empty
      end

      it 'overwrite sold_quantity returned in ML response' do
        product_variation.save
        expect(product_variation.data['sold_quantity']).to eq(1)
        product_variation.update_data(variations)
        expect(product_variation.data['sold_quantity']).to eq(1)
      end
    end

    context 'when variation_meli_id is already assigned to product_variation' do
      it 'updates the necessary attributes equally' do
        product_variation.save
        expect(product_variation.variation_meli_id).to be_nil
        product_variation.update_data(variations)
        expect(product_variation.variation_meli_id).to eq(variations['variations'][0]['id'])

        variations['variations'][0]['price'] = 100
        product_variation.update_data(variations)
        expect(product_variation.data['price']).to eq(100)
      end
    end
  end
end
