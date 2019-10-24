require 'rails_helper'
require 'vcr'

RSpec.describe MercadoLibre::Products, vcr: true do
  subject(:products_service) { described_class.new(retailer) }

  let(:retailer) { meli_retailer.retailer }
  let(:meli_retailer) { create(:meli_retailer, access_token: access_token, meli_user_id: meli_user_id) }
  let(:category) { create(:category, meli_id: 'MEC1368') }
  let(:access_token) { 'APP_USR-8747693575261051-102415-e556ce0bc1ca600d241f9ad3c2d8d637-471889087' }
  let(:meli_user_id) { '471889087' }

  describe '#search_items' do
    it 'imports the retailer products from ML' do
      VCR.use_cassette('products/items') do
        expect { products_service.search_items }.to change(Product, :count).by(8)
      end
    end
  end

  describe '#create' do
    let(:url) { 'https://miro.medium.com/max/500/1*pgsK9936_OIKWYJpcMicVg.gif' }
    let(:product) { create(:product, retailer: retailer, category: category) }

    before do
      product.attach_image(url, 'example.jpg')
    end

    it 'creates a new item in ML' do
      VCR.use_cassette('products/create_item') do
        products_service.create(product)
        expect(product.meli_product_id).not_to be_nil
      end
    end
  end

  describe '#pull_update' do
    let(:url) { 'https://miro.medium.com/max/500/1*pgsK9936_OIKWYJpcMicVg.gif' }
    let(:url2) { 'https://image.shutterstock.com/image-vector/example-red-square-grunge-stamp-260nw-327662909.jpg' }
    let(:product) { create(:product, meli_product_id: 'MEC422857056', retailer: retailer, category: category) }

    it 'pull the updates from the ML product' do
      VCR.use_cassette('products/pull_update_item') do
        products_service.pull_update(product.meli_product_id)
        expect(product.reload.meli_permalink).not_to be_nil
      end
    end

    context 'when the product does not have images attached yet' do
      it 'attaches the images to the product' do
        VCR.use_cassette('products/pull_update_item') do
          products_service.pull_update(product.meli_product_id)
          expect(product.reload.images.size).to eq(1)
        end
      end
    end

    context 'when the product already has images attached' do
      it 'attaches the images to the product and deletes the ones that do not come from ML' do
        product.attach_image(url, '756737-MEC32647573252_102019')
        product.attach_image(url, 'example.jpg')

        VCR.use_cassette('products/pull_update_item') do
          expect(product.images.size).to eq(2)

          products_service.pull_update(product.meli_product_id)
          expect(product.reload.images.size).to eq(1)
        end
      end
    end
  end

  describe '#push_change_status' do
    let(:uri) { URI("https://api.mercadolibre.com/items/MEC422857056/?access_token=#{access_token}") }
    let(:product) { create(:product, retailer: retailer, category: category) }

    before do
      VCR.use_cassette('products/create_item') do
        products_service.create(product)
      end
    end

    it 'closes the item in ML' do
      expect(product.meli_status).to eq('active')

      product.meli_status = 'closed'
      product.save

      VCR.use_cassette('products/close_meli_item') do
        products_service.push_change_status(product)

        VCR.use_cassette('products/get_close_item') do
          response = JSON.parse(Net::HTTP.get_response(uri).body)
          expect(response&.[]('status')).to eq('closed')
        end
      end
    end
  end

  describe '#push_update' do
    let(:url) { 'https://miro.medium.com/max/500/1*pgsK9936_OIKWYJpcMicVg.gif' }
    let(:product) { create(:product, available_quantity: 77, retailer: retailer, category: category) }

    before do
      product.attach_image(url, '756737-MEC32647573252_102019')

      VCR.use_cassette('products/create_item') do
        products_service.create(product)
      end
    end

    context 'when the product is active in ML' do
      let(:uri) { URI("https://api.mercadolibre.com/items/MEC422857056/?access_token=#{access_token}") }

      it 'sends the updates to ML' do
        VCR.use_cassette('products/push_update_item') do
          expect(product.available_quantity).to eq(77)

          product.available_quantity = 50
          product.save
          products_service.push_update(product)

          VCR.use_cassette('products/get_item') do
            response = JSON.parse(Net::HTTP.get_response(uri).body)
            expect(response&.[]('available_quantity')).to eq(50)
          end
        end
      end
    end
  end
end
