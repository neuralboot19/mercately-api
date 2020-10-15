require 'rails_helper'
require 'vcr'

RSpec.describe MercadoLibre::Products, vcr: true do
  subject(:products_service) { described_class.new(retailer) }

  let(:retailer) { meli_retailer.retailer }
  let(:meli_retailer) { create(:meli_retailer) }
  let(:category) { create(:category, meli_id: 'MEC1368') }
  let(:category_imported) { create(:category, meli_id: 'MEC1649') }
  let(:set_ml_categories) { instance_double(MercadoLibre::Categories) }

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

  let(:product_response) do
    {
      'id': 'MEC424912703',
      'site_id': 'MEC',
      'title': 'Computadora',
      'subtitle': nil,
      'seller_id': 471889087,
      'category_id': 'MEC1649',
      'official_store_id': nil,
      'price': nil,
      'base_price': nil,
      'original_price': nil,
      'inventory_id': nil,
      'currency_id': 'USD',
      'initial_quantity': 9,
      'available_quantity': 9,
      'sold_quantity': 0,
      'sale_terms': [],
      'buying_mode': 'buy_it_now',
      'listing_type_id': 'free',
      'start_time': '2020-03-06T01:39:10.000Z',
      'stop_time': '2020-05-04T04:00:00.000Z',
      'end_time': '2020-05-04T04:00:00.000Z',
      'expiration_time': nil,
      'condition': 'new',
      'permalink': 'https://articulo.mercadolibre.com.ec/MEC-424912703-computadora-_JM',
      'thumbnail': 'http://mec-s2-p.mlstatic.com/963548-MEC41018006190_032020-I.jpg',
      'secure_thumbnail': 'https://mec-s2-p.mlstatic.com/963548-MEC41018006190_032020-I.jpg',
      'pictures': [
        {
          'id': '963548-MEC41018006190_032020',
          'url': 'http://mec-s2-p.mlstatic.com/963548-MEC41018006190_032020-O.jpg',
          'secure_url': 'https://mec-s2-p.mlstatic.com/963548-MEC41018006190_032020-O.jpg',
          'size': '500x430',
          'max_size': '500x430',
          'quality': ''
        }
      ],
      'video_id': nil,
      'descriptions': [
        {
          'id': 'MEC424912703-2552817158'
        }
      ],
      'accepts_mercadopago': false,
      'non_mercado_pago_payment_methods': [],
      'shipping': {
        'mode': 'not_specified',
        'methods': [],
        'tags': [],
        'dimensions': nil,
        'local_pick_up': false,
        'free_shipping': false,
        'logistic_type': 'not_specified',
        'store_pick_up': false
      },
      'international_delivery_mode': 'none',
      'seller_address': {
        'address_line': 'Test Address 123',
        'city': {
          'name': 'Quito'
        },
        'state': {
          'id': 'EC-P',
          'name': 'Pichincha ( Quito )'
        },
        'country': {
          'id': 'EC',
          'name': 'Ecuador'
        },
        'id': 1065793801
      },
      'seller_contact': nil,
      'location': {},
      'coverage_areas': [],
      'attributes': [
        {
          'id': 'ITEM_CONDITION',
          'name': 'Condición del ítem',
          'value_id': '2230284',
          'value_name': 'Nuevo',
          'value_struct': nil,
          'values': [
            {
              'id': '2230284',
              'name': 'Nuevo',
              'struct': nil
            }
          ],
          'attribute_group_id': '',
          'attribute_group_name': ''
        },
        {
          'id': 'BRAND',
          'name': 'Marca',
          'value_id': nil,
          'value_name': 'Samsumg',
          'value_struct': nil,
          'values': [
            {
              'id': nil,
              'name': 'Samsumg',
              'struct': nil
            }
          ],
          'attribute_group_id': 'OTHERS',
          'attribute_group_name': 'Otros'
        }
      ],
      'warnings': [],
      'listing_source': '',
      'variations': [],
      'status': 'active',
      'sub_status': [],
      'tags': [
        'good_quality_picture',
        'test_item'
      ],
      'warranty': nil,
      'catalog_product_id': nil,
      'domain_id': 'MEC-DESKTOP_COMPUTERS',
      'seller_custom_field': nil,
      'parent_item_id': nil,
      'differential_pricing': nil,
      'deal_ids': [],
      'automatic_relist': false,
      'date_created': '2020-03-06T01:39:10.000Z',
      'last_updated': '2020-03-13T15:48:38.507Z',
      'health': nil,
      'catalog_listing': false,
      'item_relations': []
    }.with_indifferent_access
  end

  let(:product_description) do
    {
      'text': '',
      'plain_text': 'PC escritorio buena y muy confiable.',
      'last_updated': '2020-03-06T13:51:55.000Z',
      'date_created': '2020-03-06T01:39:10.000Z',
      'snapshot': {
        'url': 'http://descriptions.mlstatic.com/D-MEC424912703.jpg?hash=8520c3b8559cb08aa7e782b8f5334ffe_0x0',
        'width': 0,
        'height': 0,
        'status': ''
      }
    }.with_indifferent_access
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

      it 'not updates the product with ML information when raise an error' do
        VCR.use_cassette('products/pull_update_and_updates_item') do
          allow_any_instance_of(described_class).to receive(:after_save_data).and_raise(ActiveRecord::RecordNotUnique)

          products_service.pull_update(product.meli_product_id)
          expect(product.reload.meli_permalink).to be_nil
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

    context 'when the price of the product is null' do
      it 'does not save the product' do
        allow(set_ml_categories).to receive(:import_category)
          .with(anything).and_return(category_imported)
        allow(MercadoLibre::Categories).to receive(:new).with(retailer)
          .and_return(set_ml_categories)
        allow_any_instance_of(Product).to receive(:attach_image).and_return(true)
        allow_any_instance_of(described_class).to receive(:import_product_description)
          .and_return(product_description)
        allow(Connection).to receive(:get_request).and_return(product_response)

        expect { products_service.pull_update(product_response['id']) }.to change(Product, :count).by(0)
      end
    end

    context 'when the price of the product is not null' do
      it 'saves the product' do
        allow(set_ml_categories).to receive(:import_category)
          .with(anything).and_return(category_imported)
        allow(MercadoLibre::Categories).to receive(:new).with(retailer)
          .and_return(set_ml_categories)
        allow_any_instance_of(Product).to receive(:attach_image).and_return(true)
        allow_any_instance_of(described_class).to receive(:import_product_description)
          .and_return(product_description)
        allow(Connection).to receive(:get_request).and_return(product_response)

        product_response['price'] = 150
        expect { products_service.pull_update(product_response['id']) }.to change(Product, :count).by(1)
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

  describe '#save_product' do
    before do
      allow(set_ml_categories).to receive(:import_category)
        .with(anything).and_return(category_imported)
      allow(MercadoLibre::Categories).to receive(:new).with(retailer)
        .and_return(set_ml_categories)
      allow_any_instance_of(Product).to receive(:attach_image).and_return(true)
    end

    context 'when the price of the product is null' do
      it 'does not save the product' do
        expect { products_service.save_product(product_response, product_description) }.to change(Product, :count).by(0)
      end
    end

    context 'when the price of the product is not null' do
      it 'saves the product' do
        product_response['price'] = 150
        expect { products_service.save_product(product_response, product_description) }.to change(Product, :count).by(1)
      end
    end
  end
end
