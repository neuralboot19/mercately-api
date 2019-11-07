require 'rails_helper'
require 'vcr'

RSpec.describe MercadoLibre::ProductVariations, vcr: true do
  subject(:product_variations_service) { described_class.new(retailer) }

  let(:retailer) { meli_retailer.retailer }
  let(:meli_retailer) { create(:meli_retailer) }
  let(:category) { create(:category, meli_id: 'MEC1055') }
  let(:products_service) { MercadoLibre::Products.new(retailer) }
  let(:url) { 'https://miro.medium.com/max/500/1*pgsK9936_OIKWYJpcMicVg.gif' }
  let(:product) { create(:product, category: category, retailer: retailer, condition: 'new_product') }
  let(:meli_id_uri) do
    URI("https://api.mercadolibre.com/users/#{meli_retailer.meli_user_id}/items/search?" \
      'status=active&limit=1&orders=last_updated_desc&' \
      "access_token=#{meli_retailer.access_token}")
  end
  let(:picture_id_uri) do
    URI('https://api.mercadolibre.com/items/' \
      "#{meli_product_id}/?access_token=#{meli_retailer.access_token}")
  end
  let(:meli_product_id) do
    VCR.use_cassette('product_variations/last_product_updated_id') do
      response = JSON.parse(Net::HTTP.get_response(meli_id_uri).body)
      response['results'].first
    end
  end
  let(:main_image_id) do
    VCR.use_cassette('product_variations/get_product_main_image') do
      response = JSON.parse(Net::HTTP.get_response(picture_id_uri).body)
      response['pictures'].first['id']
    end
  end

  describe '.create_product_variations' do
    let!(:product_variation) { create(:product_variation, product: product) }

    before do
      product.attach_image(url, 'example.jpg')

      VCR.use_cassette('product_variations/create_product') do
        products_service.create(product)
      end
    end

    context 'when all the data is well formed' do
      it 'creates or updates the product variation in ML' do
        product.attach_image(url, main_image_id)
        product.update(meli_product_id: meli_product_id)

        VCR.use_cassette('product_variations/create_product_variation') do
          product_variations_service.create_product_variations(product)
          expect(product_variation.reload.variation_meli_id).not_to be_nil
        end
      end
    end

    context 'when the available_quantity is not correct' do
      before do
        product.attach_image(url, main_image_id)
        product.update(meli_product_id: meli_product_id)
        product_variation.data['attribute_combinations'][0]['value_name'] = 'Azul'
        product_variation.data['available_quantity'] = -1
        product_variation.save
      end

      it 'does not create or update the product variation in ML' do
        VCR.use_cassette('product_variations/do_not_create_product_variation') do
          product_variations_service.create_product_variations(product)
          expect(product_variation.reload.variation_meli_id).to be_nil
        end
      end
    end
  end

  describe '.save_variations' do
    let(:variation_1) do
      [
        {
          id: 1_497_933_258_9,
          attribute_combinations: [
            {
              id: 'COLOR',
              name: 'Color',
              value_id: '52049',
              value_name: 'Negro'
            }
          ],
          price: 50.5,
          available_quantity: 5,
          sold_quantity: 0,
          picture_ids: [
            '553111-MLA20482692355_112015'
          ]
        }.with_indifferent_access
      ]
    end
    let(:variation_2) do
      [
        {
          id: 1_497_933_259_2,
          attribute_combinations: [
            {
              id: 'COLOR',
              name: 'Color',
              value_id: '52005',
              value_name: 'Marrón'
            }
          ],
          price: 100,
          available_quantity: 4,
          sold_quantity: 0,
          picture_ids: [
            '553111-MLA20482692355_112015'
          ]
        }.with_indifferent_access
      ]
    end

    context 'when the product variation comes from a parent' do
      let(:product_variation) { create(:product_variation, product: product, variation_meli_id: 1_234_567_891_0) }
      let(:variations) { variation_1 }

      it 'updates the matching variation with the new data' do
        expect(product_variation.variation_meli_id).to eq(1_234_567_891_0)
        product_variations_service.save_variations(product, variations, true)
        expect(product_variation.reload.variation_meli_id).to eq(1_497_933_258_9)
      end
    end

    context 'when the product variation does not come from a parent' do
      let(:variations) { variation_1 + variation_2 }

      it 'creates or updates the product variations in Mercately' do
        product_variations_service.save_variations(product, variations)
        expect(product.reload.product_variations.size).to eq(2)
      end
    end
  end
end
