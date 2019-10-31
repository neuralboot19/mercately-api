require 'rails_helper'
require 'vcr'

RSpec.describe MercadoLibre::Products, vcr: true do
  subject(:products_service) { described_class.new(retailer) }

  let(:retailer) { meli_retailer.retailer }
  let(:meli_retailer) { create(:meli_retailer) }
  let(:category) { create(:category, meli_id: 'MEC1368') }
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
    VCR.use_cassette('products/last_product_updated_id') do
      response = JSON.parse(Net::HTTP.get_response(meli_id_uri).body)
      response['results'].first
    end
  end
  let(:main_image_id) do
    VCR.use_cassette('products/get_item_main_image') do
      response = JSON.parse(Net::HTTP.get_response(picture_id_uri).body)
      response['pictures'].first['id']
    end
  end

  describe '#search_items' do
    let(:uri) do
      URI("https://api.mercadolibre.com/users/#{meli_retailer.meli_user_id}/items/search" \
        "?status=active&access_token=#{meli_retailer.access_token}")
    end
    let!(:total_active_items) do
      VCR.use_cassette('products/get_active_items') do
        response = JSON.parse(Net::HTTP.get_response(uri).body)
        response['paging']['total']
      end
    end

    it 'imports the retailer products from ML' do
      VCR.use_cassette('products/items') do
        expect { products_service.search_items }.to change(Product, :count).by(total_active_items)
      end
    end
  end

  describe '#create' do
    let(:url) { 'https://miro.medium.com/max/500/1*pgsK9936_OIKWYJpcMicVg.gif' }
    let(:product) do
      create(:product, retailer: retailer, category: category, condition: 'used', available_quantity: 77)
    end

    before do
      product.attach_image(url, 'example.jpg')
    end

    context 'when all data is well formed' do
      it 'creates a new item in ML' do
        VCR.use_cassette('products/create_item') do
          products_service.create(product)
          expect(product.meli_product_id).not_to be_nil
        end
      end
    end

    context 'when the available quantity is zero' do
      it 'does not create a new item in ML' do
        product.update(available_quantity: 0)
        expect(product.meli_product_id).to be_nil

        VCR.use_cassette('products/do_not_create_item') do
          products_service.create(product)
          expect(product.meli_product_id).to be_nil
        end
      end
    end
  end

  describe '#pull_update' do
    let(:url) { 'https://miro.medium.com/max/500/1*pgsK9936_OIKWYJpcMicVg.gif' }
    let(:product) do
      create(:product, retailer: retailer, category: category, condition: 'used', available_quantity:
        77, meli_product_id: meli_product_id)
    end

    context 'when product does not exist in Mercately' do
      it 'creates the product with ML information' do
        VCR.use_cassette('products/pull_update_and_creates_item') do
          meli_id = product.meli_product_id
          product.destroy
          expect { products_service.pull_update(meli_id) }.to change(Product, :count).by(1)
        end
      end
    end

    context 'when product already exists in Mercately' do
      it 'updates the product with ML information' do
        VCR.use_cassette('products/pull_update_and_updates_item') do
          products_service.pull_update(product.meli_product_id)
          expect(product.reload.meli_permalink).not_to be_nil
        end
      end
    end

    context 'when the product does not have images attached yet' do
      it 'attaches the images to the product' do
        VCR.use_cassette('products/pull_update_and_updates_item') do
          products_service.pull_update(product.meli_product_id)
          expect(product.reload.images.size).to eq(1)
        end
      end
    end

    context 'when the product already has images attached' do
      it 'attaches the images to the product and deletes the ones that do not come from ML' do
        product.attach_image(url, main_image_id)
        product.attach_image(url, 'example.jpg')

        VCR.use_cassette('products/pull_update_and_updates_item') do
          expect(product.images.size).to eq(2)

          products_service.pull_update(product.meli_product_id)

          expect(product.reload.images.size).to eq(1)
        end
      end
    end
  end

  describe '#load_main_picture' do
    let(:url) { 'https://miro.medium.com/max/500/1*pgsK9936_OIKWYJpcMicVg.gif' }
    let(:uri) do
      URI("https://api.mercadolibre.com/items/#{product.meli_product_id}/" \
        "?access_token=#{meli_retailer.access_token}")
    end
    let(:product) do
      create(:product, retailer: retailer, category: category, condition: 'used', available_quantity:
        77, meli_product_id: meli_product_id)
    end

    before do
      product.attach_image(url, main_image_id)
      product.attach_image(url, 'example.jpg')
    end

    it 'upload the new images to ML' do
      VCR.use_cassette('products/load_main_picture') do
        products_service.load_main_picture(product, false)

        VCR.use_cassette('products/get_item_with_images') do
          response = JSON.parse(Net::HTTP.get_response(uri).body)

          expect(response['pictures'].size).to eq(2)
        end
      end
    end
  end

  describe '#push_update' do
    let(:url) { 'https://miro.medium.com/max/500/1*pgsK9936_OIKWYJpcMicVg.gif' }
    let(:product) do
      create(:product, retailer: retailer, category: category, condition: 'used', available_quantity:
        77, meli_product_id: meli_product_id)
    end

    before do
      product.attach_image(url, main_image_id)
    end

    context 'when the product is active in ML' do
      let(:uri) do
        URI("https://api.mercadolibre.com/items/#{product.meli_product_id}/" \
          "?access_token=#{meli_retailer.access_token}")
      end

      it 'sends the updates to ML' do
        VCR.use_cassette('products/push_update_item') do
          expect(product.available_quantity).to eq(77)

          product.update(available_quantity: 50)
          products_service.push_update(product)

          VCR.use_cassette('products/get_item') do
            response = JSON.parse(Net::HTTP.get_response(uri).body)
            expect(response['available_quantity']).to eq(50)
          end
        end
      end
    end

    context 'when the product is deactive in ML' do
      let(:uri) do
        URI("https://api.mercadolibre.com/users/#{meli_retailer.meli_user_id}/items/search?" \
          'status=active&limit=1&orders=last_updated_desc&' \
          "access_token=#{meli_retailer.access_token}")
      end
      let(:uri2) do
        URI("https://api.mercadolibre.com/items/#{last_re_publish_item_id}/" \
          "?access_token=#{meli_retailer.access_token}")
      end
      let(:last_re_publish_item_id) do
        VCR.use_cassette('products/last_re_publish_item_id') do
          response = JSON.parse(Net::HTTP.get_response(uri).body)
          response['results'].first
        end
      end
      let(:re_publish_item) do
        VCR.use_cassette('products/get_re_publish_item') do
          JSON.parse(Net::HTTP.get_response(uri2).body)
        end
      end

      it 're publishes the product in ML' do
        product.update(meli_status: 'closed')

        VCR.use_cassette('products/close_item_for_re_publish') do
          products_service.push_change_status(product)

          VCR.use_cassette('products/re_publish_item') do
            products_service.push_update(product, 'closed', true)

            expect(re_publish_item['parent_item_id']).to eq(product.meli_product_id)
          end
        end
      end
    end
  end

  describe '#push_change_status' do
    let(:url) { 'https://miro.medium.com/max/500/1*pgsK9936_OIKWYJpcMicVg.gif' }
    let(:uri) do
      URI("https://api.mercadolibre.com/items/#{product.meli_product_id}/" \
        "?access_token=#{meli_retailer.access_token}")
    end
    let(:product) do
      create(:product, retailer: retailer, category: category, condition: 'used', available_quantity: 77)
    end

    before do
      product.attach_image(url, 'example.jpg')

      VCR.use_cassette('products/create_item_for_close') do
        products_service.create(product)
      end
    end

    it 'closes the item in ML' do
      VCR.use_cassette('products/close_meli_item') do
        product.update(meli_status: 'closed')
        products_service.push_change_status(product)

        VCR.use_cassette('products/get_close_item') do
          response = JSON.parse(Net::HTTP.get_response(uri).body)
          expect(response['status']).to eq('closed')
        end
      end
    end
  end
end
