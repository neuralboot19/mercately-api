require 'rails_helper'

RSpec.describe Product, type: :model do
  subject(:product) { create(:product) }

  describe 'associations' do
    it { is_expected.to belong_to(:retailer) }
    it { is_expected.to belong_to(:category) }

    it { is_expected.to have_many(:order_items) }
    it { is_expected.to have_many(:questions) }
    it { is_expected.to have_many(:product_variations) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:buying_mode).with_values(%i[buy_it_now classified]) }
    it { is_expected.to define_enum_for(:condition).with_values(%i[new_product used not_specified]) }
    it { is_expected.to define_enum_for(:status).with_values(%i[active archived]).with_prefix }

    it {
      expect(product).to define_enum_for(:meli_status)
        .with_values(%i[active payment_required paused closed under_review inactive])
    }
  end

  describe '#attach_image(url, filename, index = -1)' do
    let(:url) { 'https://miro.medium.com/max/500/1*pgsK9936_OIKWYJpcMicVg.gif' }

    it 'uploads from ML to Cloudinary and sets the main picture' do
      expect(product.attach_image(url, 'tio_ben.gif', 0)).to eq 1
      expect(product.main_picture_id).not_to be_nil
    end

    context 'when the image already exists' do
      it 'deletes the local file' do
        product.attach_image(url, 'tio_ben.gif', 0)
        expect(product.attach_image(url, 'tio_ben.gif', 0)).to eq 1
      end
    end
  end

  describe '#earned' do
    before do
      create_list(:order_item, 5, product: product, quantity: 2, unit_price: 5)
    end

    it 'returns the earned amount' do
      expect(product.earned).to eq 50
    end
  end

  describe '#update_main_picture' do
    let(:url) { 'https://miro.medium.com/max/500/1*pgsK9936_OIKWYJpcMicVg.gif' }
    let(:url2) { 'https://image.shutterstock.com/image-vector/example-red-square-grunge-stamp-260nw-327662909.jpg' }
    let(:set_ml_products) { instance_double(MercadoLibre::Products) }

    before do
      allow(set_ml_products).to receive(:load_main_picture)
        .with(anything, anything).and_return('Successfully uploaded')
      allow(MercadoLibre::Products).to receive(:new).with(product.retailer)
        .and_return(set_ml_products)
    end

    it 'updates the main picture' do
      product.attach_image(url, 'tio_ben.gif', 0)
      product.attach_image(url, 'example.jpg')
      product.update_main_picture('example.jpg')
      expect(product.main_picture_id).to eq product.images.last.id
    end
  end

  describe '#upload_ml' do
    it 'returns nil if retailer is not connected to ML' do
      expect(product.upload_ml).to be_nil
    end

    context 'when retailer is connected to ML' do
      let!(:meli_retailer) { create(:meli_retailer, retailer: product.retailer) }
      let(:set_ml_products) { instance_double(MercadoLibre::Products) }

      before do
        allow(set_ml_products).to receive(:create)
          .with(anything).and_return('Successfully uploaded')
        allow(MercadoLibre::Products).to receive(:new).with(product.retailer)
          .and_return(set_ml_products)
      end

      context 'when the attribute to upload the product to ML is not checked' do
        it 'does not upload the product to ML' do
          product.upload_product = false
          expect(product.upload_ml).to be_nil
        end
      end

      context 'when the attribute to upload the product to ML is checked' do
        it 'uploads the product to ML' do
          product.upload_product = true
          expect(product.upload_ml).to eq 'Successfully uploaded'
        end
      end
    end
  end

  describe '#upload_variations' do
    let(:variation_1) do
      [
        {
          'id' => 'variation_1',
          attribute_combinations: [
            {
              id: 'COLOR',
              value_name: 'Blanco'
            }
          ],
          picture_ids: [],
          'available_quantity' => '5',
          'sold_quantity' => '',
          'price' => '10'
        }
      ]
    end
    let(:variation_2) do
      [
        {
          'id' => 'variation_2',
          attribute_combinations: [
            {
              id: 'COLOR',
              value_name: 'Naranja'
            }
          ],
          picture_ids: [],
          'available_quantity' => '7',
          'sold_quantity' => '',
          'price' => '10'
        }
      ]
    end
    let(:variations) { variation_1 + variation_2 }

    it 'returns nil if product has no variations' do
      expect(product.upload_variations('create', nil)).to be_nil
    end

    context 'with product variations' do
      let!(:meli_retailer) { create(:meli_retailer, retailer: product.retailer) }
      let(:p_ml) { instance_double(MercadoLibre::ProductVariations) }

      before do
        allow(p_ml).to receive(:create_product_variations)
          .with(anything).and_return('Successfully uploaded')
        allow(MercadoLibre::ProductVariations).to receive(:new).with(product.retailer)
          .and_return(p_ml)
      end

      context 'when the attribute to upload the product to ML is not checked or the
        product is not linked to ML' do
        it 'does not upload the product variations to ML' do
          product.upload_product = false
          expect(product.upload_variations(anything, variations)).to be_nil
        end
      end

      context 'when the attribute to upload the product to ML is checked or the
        product is linked to ML' do
        it 'uploads the product variations to ML' do
          product.upload_product = true
          expect(product.upload_variations(anything, variations)).to eq 'Successfully uploaded'
        end
      end

      context 'when action_name is new or create' do
        it 'creates the product variations' do
          expect { product.upload_variations('new', variations) }.to change(ProductVariation, :count).by(2)
        end
      end

      context 'when action_name is edit or update' do
        it 'updates the product variations' do
          variation_2[0]['id'] = 'variation_1'
          product.upload_variations('new', variation_1)
          product_variation = product.product_variations.last
          product_variation.update(variation_meli_id: variation_2[0]['id'])
          product.upload_variations('edit', variation_2)
          expect(product_variation.reload.data).to eq variation_2[0].as_json
        end

        it 'creates the product variation if does not exist' do
          variation_1[0]['id'] = nil
          expect { product.upload_variations('edit', variation_1) }.to change(ProductVariation, :count).by(1)
        end
      end
    end
  end

  describe '#delete_images' do
    it 'returns nil if product has no imgs' do
      expect(product.delete_images(nil, nil, nil)).to be_nil
    end

    context 'with product imgs' do
      it 'removes selected imgs' do
        expect(product.delete_images(product.images, 'variations', nil)).to be_nil
      end
    end

    context 'with product imgs' do
      subject(:product) { create(:product, :from_ml) }

      let(:url) { 'https://miro.medium.com/max/500/1*pgsK9936_OIKWYJpcMicVg.gif' }
      let(:set_ml_products) { instance_double(MercadoLibre::Products) }
      let!(:meli_retailer) { create(:meli_retailer, retailer: product.retailer) }

      before do
        allow(set_ml_products).to receive(:push_update)
          .with(anything, anything, anything).and_return('Successfully uploaded')
        allow(MercadoLibre::Products).to receive(:new).with(product.retailer)
          .and_return(set_ml_products)
        product.attach_image(url, 'tio_ben.gif', 0)
      end

      it 'removes selected imgs and push to ML' do
        expect(product.delete_images(product.images, nil, 'active')).to eq 'Successfully uploaded'
      end
    end
  end

  describe '#disabled_meli_statuses' do
    let(:disabled) { %w[payment_required under_review inactive] }

    context 'when meli_status is archived' do
      it 'returns an array with posible statuses' do
        product.update(status: 'archived')
        expect(product.disabled_meli_statuses).to eq disabled + %w[active paused closed]
      end
    end

    context 'when meli_status is active' do
      it 'returns an array with posible statuses' do
        product.update(meli_status: 'active')
        expect(product.disabled_meli_statuses).to eq disabled
      end
    end

    context 'when meli_status is closed' do
      it 'returns an array with posible statuses' do
        product.update(meli_status: 'closed')
        expect(product.disabled_meli_statuses).to eq disabled + %w[paused]
      end
    end

    context 'when meli_status is paused' do
      it 'returns an array with posible statuses' do
        product.update(meli_status: 'paused')
        expect(product.disabled_meli_statuses).to eq disabled + %w[closed]
      end
    end
  end

  describe '#update_variations_quantities' do
    it 'returns nil if has no variations' do
      expect(product.update_variations_quantities).to be_nil
    end

    context 'when product has variations' do
      let!(:product_variation) { create(:product_variation, product: product) }

      it 'updates the available_quantity and sold_quantity' do
        product.update_variations_quantities
        expect(product.available_quantity).to eq product_variation.data['available_quantity'].to_i
        expect(product.sold_quantity).to eq product_variation.data['sold_quantity'].to_i
      end
    end
  end

  describe '#include_before_bids_info?' do
    it 'returns false if there are orders from ML' do
      order = create(:order, :from_ml, :cancelled, feedback_reason: nil)
      create(:order_item, product: product, order: order)
      expect(product.include_before_bids_info?).to eq false
    end
  end
end
