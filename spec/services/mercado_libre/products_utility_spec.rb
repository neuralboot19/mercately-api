require 'rails_helper'

RSpec.describe MercadoLibre::ProductsUtility do
  subject(:products_utility_service) { described_class.new }

  let(:product) { create(:product) }

  describe '.prepare_product' do
    it 'returns the product data' do
      response = JSON.parse(products_utility_service.prepare_product(product))

      expect(response['title']).to eq(product.title)
    end

    context 'when the product has a valid condition' do
      it 'returns the condition value' do
        product.update(condition: 'new_product')
        response = JSON.parse(products_utility_service.prepare_product(product))

        expect(response['condition']).to eq('new')
      end
    end

    context 'when the product does not have a condition' do
      it 'returns not a specified condition' do
        product.update(condition: nil)
        response = JSON.parse(products_utility_service.prepare_product(product))

        expect(response['condition']).to eq('not_specified')
      end
    end
  end

  describe '.prepare_images' do
    let(:url) { 'https://miro.medium.com/max/500/1*pgsK9936_OIKWYJpcMicVg.gif' }

    before do
      product.attach_image(url, 'tio_ben.gif', 0)
      product.attach_image(url, 'example.jpg')
    end

    it 'returns an Array with the product images' do
      response = products_utility_service.prepare_images(product)

      expect(response.size).to eq(product.images.size)
    end
  end

  describe '.prepare_images_update' do
    let(:url) { 'https://miro.medium.com/max/500/1*pgsK9936_OIKWYJpcMicVg.gif' }

    context 'when images have the ML ID as filename' do

      before do
        product.attach_image(url, '873411-MLA20547233702_012016', 0)
        product.attach_image(url, '873411-MLA20547233702_238945')
      end

      it 'returns an Array with the product images' do
        response = products_utility_service.prepare_images_update(product)

        expect(response.size).to eq(product.images.size)
      end
    end

    context 'when not all the images have the ML ID as filename' do

      before do
        product.attach_image(url, '873411-MLA20547233702_012016', 0)
        product.attach_image(url, 'example.jpg')
      end

      it 'returns an Array with the product images having the ML ID as filename' do
        response = products_utility_service.prepare_images_update(product)

        expect(response.size).to eq(1)
      end
    end
  end

  describe '.prepare_product_update' do
    let(:product_variation) { build(:product_variation, product: product) }

    it 'returns the product data' do
      response = JSON.parse(products_utility_service.prepare_product_update(product, 'active'))

      expect(response['title']).to eq(product.title)
    end

    context 'when the product does not have variations' do
      it 'the product price is included in the returned object' do
        response = JSON.parse(products_utility_service.prepare_product_update(product, 'active'))

        expect(response['price']).not_to be_nil
      end
    end

    context 'when the product has variations' do
      it 'they are included in the returned object' do
        product_variation.save
        response = JSON.parse(products_utility_service.prepare_product_update(product, 'active'))

        expect(response['variations']).not_to be_nil
      end
    end
  end

  describe '.prepare_product_description_update' do
    it 'returns the product description' do
      response = JSON.parse(products_utility_service.prepare_product_description_update(product))

      expect(response['plain_text']).to eq(product.description)
    end
  end

  describe '.prepare_variation_product' do
    let(:product_variation) { create(:product_variation, :from_ml, product: product) }
    let(:url) { 'https://miro.medium.com/max/500/1*pgsK9936_OIKWYJpcMicVg.gif' }

    before do
      product.attach_image(url, 'tio_ben.gif', 0)
      product.attach_image(url, 'example.jpg')
    end

    it 'returns the product variations' do
      response = JSON.parse(products_utility_service.prepare_variation_product(product_variation, product))

      expect(response['variations'].size).to eq(2)
    end

    context 'when the variation includes an undefined id in data attribute' do
      it 'excludes that id from data' do
        product_variation.data['id'] = 'undefined'
        product_variation.save

        response = JSON.parse(products_utility_service.prepare_variation_product(product_variation, product))

        expect(response['variations'][1]['id']).to be_nil
      end
    end
  end

  describe '.prepare_re_publish_product' do
    let(:product_variation) { build(:product_variation, product: product) }

    it 'returns the product data' do
      response = JSON.parse(products_utility_service.prepare_re_publish_product(product))

      expect(response['listing_type_id']).to eq('free')
    end

    context 'when the product does not have variations' do
      it 'returns the price and quantity in the product object' do
        response = JSON.parse(products_utility_service.prepare_re_publish_product(product))

        expect(response['price']).to eq(product.price.to_f)
        expect(response['quantity']).to eq(product.available_quantity)
      end
    end

    context 'when the product has variations' do
      it 'returns the price and quantity in the product object' do
        product_variation.save
        response = JSON.parse(products_utility_service.prepare_re_publish_product(product))

        expect(response['variations'][0]['price']).to eq(product_variation.data['price'].to_f)
        expect(response['variations'][0]['quantity']).to eq(product_variation.data['available_quantity'])
      end
    end
  end

  describe '.prepare_product_status_update' do
    it 'returns the ML status of the product' do
      product.update(meli_status: 'active')

      response = JSON.parse(products_utility_service.prepare_product_status_update(product))

      expect(response['status']).to eq(product.meli_status)
    end
  end

  describe '.assign_product' do
    let(:new_product) { build(:product, :from_ml) }
    let(:product_info) do
      {
        id: 'MEC123456789',
        condition: 'new',
        sold_quantity: 3,
        available_quantity: 0
      }.with_indifferent_access
    end

    context 'when the product is a new_record' do
      it 'sets the sold_quantity attribute' do
        products_utility_service.assign_product(new_product, product_info, product.retailer, product.category, false)

        expect(new_product.sold_quantity).to eq(product_info['sold_quantity'])
      end
    end

    context 'when the product comes from a parent' do
      it 'updates the meli_product_id' do
        products_utility_service.assign_product(new_product, product_info, product.retailer, product.category, true)

        expect(new_product.meli_product_id).to eq(product_info['id'])
      end
    end

    context 'when the product is not archived and the incoming status is closed' do
      it 'sets the available_quantity of the product to 0' do
        product_info['status'] = 'closed'
        products_utility_service.assign_product(new_product, product_info, product.retailer, product.category, false)

        expect(new_product.available_quantity).to eq(0)
      end
    end
  end

  describe '.new_product_has_parent?' do
    let(:ml_product) { create(:product, :from_ml) }
    let(:new_product) { build(:product, :from_ml) }
    let(:product_info) do
      {
        parent_item_id: 'MEC123456789'
      }.with_indifferent_access
    end

    context 'when the product comes from a parent, and the parent does not exist in DB' do
      it 'returns false' do
        expect(products_utility_service.new_product_has_parent?(new_product, product_info)).to be false
      end
    end

    context 'when the product comes from a parent, and the parent does not exist in DB' do
      it 'returns true' do
        product_info['parent_item_id'] = ml_product.meli_product_id
        expect(products_utility_service.new_product_has_parent?(new_product, product_info)).to be true
      end
    end
  end
end
