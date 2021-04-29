require 'rails_helper'

RSpec.describe Product, type: :model do
  subject(:product) { create(:product, incoming_variations: variation) }

  let(:variation) do
    [
      {
        'id' => 'variation_id',
        attribute_combinations: [
          {
            id: 'BRAND',
            value_name: 'Gucci'
          }
        ],
        picture_ids: [],
        'available_quantity' => '7',
        'sold_quantity' => '0',
        'price' => '10.5'
      }
    ]
  end

  describe 'associations' do
    it { is_expected.to belong_to(:retailer).without_validating_presence }
    it { is_expected.to belong_to(:category).optional }

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

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:price) }
    it { is_expected.to validate_uniqueness_of(:code).scoped_to(:retailer_id).with_message('Código ya está en uso.').allow_blank }
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
      order = create(:order, :completed)
      create_list(:order_item, 5, order: order, product: product, quantity: 2, unit_price: 5)
    end

    it 'returns the earned amount' do
      expect(product.earned).to eq 50
    end
  end

  describe '#update_main_picture' do
    let(:url) { 'https://miro.medium.com/max/500/1*pgsK9936_OIKWYJpcMicVg.gif' }
    let(:set_ml_products) { instance_double(MercadoLibre::Products) }

    before do
      allow(set_ml_products).to receive(:load_main_picture)
        .with(anything, anything).and_return('Successfully uploaded')
      allow(MercadoLibre::Products).to receive(:new).with(product.retailer)
        .and_return(set_ml_products)
    end

    context 'when there are not images attached' do
      it 'returns nil' do
        expect(product.update_main_picture).to be_nil
      end
    end

    context 'when there are images attached' do
      it 'updates the main picture' do
        tempfile = MiniMagick::Image.open(url)
        tempfile.write('./public/upload-testing.jpg')
        file = ActionDispatch::Http::UploadedFile.new(filename: 'main_image.jpg', content_type:
          'image/jpg', tempfile: tempfile.path)

        product.main_image = file
        product.update_main_picture
        File.delete('./public/upload-testing.jpg')
        expect(product.main_picture_id).to eq(product.images.last.id)
      end
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
          .and_return('Successfully uploaded')
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
          .and_return('Successfully uploaded')
        allow(MercadoLibre::ProductVariations).to receive(:new).with(product.retailer)
          .and_return(p_ml)
      end

      # context 'when the product is not linked to ML' do
        # it 'does not upload the product variations to ML' do
          # product.upload_product = false
          # expect(product.upload_variations(anything, variations)).to be_nil
        # end
      # end

      # context 'when the product is linked to ML' do
        # it 'uploads the product variations to ML' do
          # product.upload_product = true
          # expect(product.upload_variations(anything, variations)).to eq 'Successfully uploaded'
        # end
      # end

      context 'when the attribute variation_id is defined' do
        let(:variation_3) do
          [
            {
              'variation_id' => 'variation_3',
              attribute_combinations: [
                {
                  id: 'COLOR',
                  value_name: 'Azul'
                }
              ],
              picture_ids: [],
              'available_quantity' => '8',
              'sold_quantity' => '',
              'price' => '11'
            }
          ]
        end

        # it 'uploads variations' do
          # create(:product_variation, product: product , id: variation_3[0]['variation_id'])
          # product.upload_product = true
          # expect(product.upload_variations('update', variation_3)).to eq 'Successfully uploaded'
        # end
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
    context 'with product imgs' do
      it 'removes selected imgs' do
        expect(product.delete_images(product.images, 'variations', nil)).to be_nil
      end
    end

    context 'with product imgs' do
      subject(:product) { create(:product, :from_ml, incoming_variations: variation) }

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
        expect(product.delete_images({ '0': product.images.first.id }, nil, 'active')).to eq 'Successfully uploaded'
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

  describe '#check_variations' do
    subject(:product) { build(:product, category: create(:category, :with_variations)) }

    context 'when the category of the product needs variations' do
      it 'asks for at least one variation' do
        product.save
        expect(product.errors['base'].include?('Debe agregar al menos una variación.')).to be true
      end
    end

    context 'when the category of the product does not need variations' do
      it 'does not ask for variations' do
        product.category.save
        expect(product.errors['base'].include?('Debe agregar al menos una variación.')).to be false
      end
    end
  end

  describe '#check_images' do
    subject(:product) { build(:product) }

    context 'when the product is being created' do
      let(:retailer) { create(:retailer) }
      let(:meli_retailer) { create(:meli_retailer, retailer: retailer) }

      before do
        product.retailer = meli_retailer.retailer
      end

      context 'when uploading the product to ML' do
        it 'asks for at least one image' do
          product.upload_product = true
          product.save
          expect(product.errors['base'].include?('Debe agregar entre 1 y 10 imágenes.')).to be true
        end
      end

      context 'when not uploading the product to ML' do
        it 'does not ask for images' do
          product.upload_product = false
          product.save
          expect(product.errors['base'].include?('Debe agregar entre 1 y 10 imágenes.')).to be false
        end
      end
    end

    context 'when the product is being updated' do
      let(:url) { 'https://miro.medium.com/max/500/1*pgsK9936_OIKWYJpcMicVg.gif' }
      let(:retailer) { create(:retailer) }
      let(:meli_retailer) { create(:meli_retailer, retailer: retailer) }

      before do
        product.retailer = meli_retailer.retailer
        product.save
      end

      context 'when uploading the product to ML or the product is linked to ML' do
        it 'asks for at least one image' do
          product.meli_product_id = '1234567890'
          product.upload_product = true
          product.save
          expect(product.errors['base'].include?('Debe agregar entre 1 y 10 imágenes.')).to be true

          product.errors.clear
          product.attach_image(url, 'example.jpg')
          product.deleted_images = { '0': product.images.first.id.to_s }
          product.save
          expect(product.errors['base'].include?('Debe agregar entre 1 y 10 imágenes.')).to be true
        end
      end

      context 'when not uploading the product to ML' do
        it 'does not ask for images' do
          product.upload_product = false
          product.save
          expect(product.errors['base'].include?('Debe agregar entre 1 y 10 imágenes.')).to be false
        end
      end
    end
  end

  describe '#product_without_images?' do
    context 'when the product does not have images' do
      it 'returns true' do
        expect(product.product_without_images?).to be true
      end
    end

    context 'when the product has images' do
      let(:url) { 'https://miro.medium.com/max/500/1*pgsK9936_OIKWYJpcMicVg.gif' }

      it 'returns false' do
        product.attach_image(url, 'example.jpg')
        expect(product.product_without_images?).to be false
      end
    end
  end

  describe '#nullify_code' do
    context 'when the code attribute is blank' do
      let(:product) { build(:product, code: '') }

      it 'sets to nil the code attribute before save' do
        expect(product.code).to eq('')
        product.save
        expect(product.code).to be_nil
      end
    end

    context 'when the code attribute is not blank' do
      let(:product) { build(:product, code: 'PRODUCTO') }

      it 'does not set to nil the code attribute before save' do
        expect(product.code).to eq('PRODUCTO')
        product.save
        expect(product.code).not_to be_nil
      end
    end
  end

  describe '#range_total_sold' do
    let(:order) { create(:order, status: 'success') }

    before do
      create_list(:order_item, 2, product: product, order: order, quantity: 2)
    end

    it 'returns the total items sold of the product' do
      start_date = 1.day.ago
      end_date = Time.now
      expect(product.range_total_sold(start_date, end_date)).to eq(4)
    end
  end

  describe '#range_total_earned' do
    let(:order) { create(:order, status: 'success') }

    before do
      create_list(:order_item, 2, product: product, order: order, quantity: 2, unit_price: 12.5)
    end

    it 'returns the total items sold of the product' do
      start_date = 1.day.ago
      end_date = Time.now
      expect(product.range_total_earned(start_date, end_date)).to eq(50)
    end
  end

  describe '#generate_web_id' do
    let(:product) { build(:product) }

    it 'generates the web_id field to products' do
      expect(product.web_id).to be_nil
      product.save
      expect(product.web_id).not_to be_nil
    end
  end

  describe '#sort_by_earned' do
    let(:retailer) { create(:retailer) }
    let(:product1) { create(:product, retailer: retailer) }
    let(:product2) { create(:product, retailer: retailer) }
    let(:order1) { create(:order, status: 'success') }
    let(:order2) { create(:order, status: 'success') }
    let!(:order_item1) { create(:order_item, order: order1, product: product1, quantity: 1, unit_price: 50) }
    let!(:order_item2) { create(:order_item, order: order2, product: product2, quantity: 2, unit_price: 35) }

    context 'when the order is ascending' do
      it 'returns the product with less profit first' do
        params = { q: { s: 'sort_by_earned asc' } }
        result = retailer.products.ransack(params[:q]).result
        expect(result.first).to eq(order_item1.product)
      end
    end

    context 'when the order is descending' do
      it 'returns the product with more profit first' do
        params = { q: { s: 'sort_by_earned desc' } }
        result = retailer.products.ransack(params[:q]).result
        expect(result.first).to eq(order_item2.product)
      end
    end
  end

  describe '#sort_by_order_items_count' do
    let(:retailer) { create(:retailer) }
    let(:product1) { create(:product, retailer: retailer) }
    let!(:product2) { create(:product, retailer: retailer) }
    let(:order1) { create(:order, status: 'success') }
    let(:order2) { create(:order, status: 'success') }
    let!(:order_item1) { create(:order_item, order: order1, product: product1) }
    let!(:order_item2) { create(:order_item, order: order2, product: product1) }

    context 'when the order is ascending' do
      it 'returns the product with less orders' do
        params = { q: { s: 'sort_by_order_items_count asc' } }
        result = retailer.products.ransack(params[:q]).result
        expect(result.first).to eq(product2)
      end
    end

    context 'when the order is descending' do
      it 'returns the product with more orders' do
        params = { q: { s: 'sort_by_order_items_count desc' } }
        result = retailer.products.ransack(params[:q]).result
        expect(result.first).to eq(product1)
      end
    end
  end

  describe '#to_param' do
    it 'returns the product web_id' do
      expect(product.to_param).to eq(product.web_id)
    end
  end

  describe '#upload_facebook' do
    it 'returns nil if retailer is not connected to Facebook Catalog' do
      expect(product.upload_facebook).to be_nil
    end

    context 'when retailer is connected to Facebook Catalog' do
      let!(:facebook_catalog) { create(:facebook_catalog, retailer: product.retailer) }
      let(:set_fb_products) { instance_double(Facebook::Products) }

      before do
        allow(set_fb_products).to receive(:create)
          .and_return('Successfully uploaded')
        allow(Facebook::Products).to receive(:new).with(product.retailer)
          .and_return(set_fb_products)
      end

      context 'when the attribute to upload the product to Facebook Catalog is not checked' do
        it 'does not upload the product' do
          product.upload_to_facebook = false
          expect(product.upload_facebook).to be_nil
        end
      end

      context 'when the attribute to upload the product to Facebook Catalog is checked' do
        it 'uploads the product' do
          product.upload_to_facebook = true
          expect(product.upload_facebook).to eq 'Successfully uploaded'
        end
      end
    end
  end

  describe '#update_facebook_product' do
    let(:set_fb_products) { instance_double(Facebook::Products) }

    it 'returns nil if the product does not have facebook product id set' do
      expect(product.update_facebook_product).to be_nil
    end

    context 'when the available quantity is positive' do
      it 'updates the product on facebook catalog' do
        allow(set_fb_products).to receive(:update_or_upload)
          .and_return('Successfully updated')
        allow(Facebook::Products).to receive(:new).with(product.retailer)
          .and_return(set_fb_products)

        product.update(facebook_product_id: '123456789')
        expect(product.update_facebook_product).to eq 'Successfully updated'
      end
    end

    context 'when the available quantity is not positive' do
      it 'deletes the product on facebook catalog' do
        allow(set_fb_products).to receive(:delete)
          .and_return('Successfully deleted')
        allow(Facebook::Products).to receive(:new).with(product.retailer)
          .and_return(set_fb_products)

        product.update(facebook_product_id: '123456789', available_quantity: 0)
        expect(product.update_facebook_product).to eq 'Successfully deleted'
      end
    end
  end

  describe '#update_facebook_inventory' do
    let(:set_fb_products) { instance_double(Facebook::Products) }

    it 'returns nil if the product does not have facebook product id set' do
      expect(product.send(:update_facebook_inventory)).to be_nil
    end

    context 'when the available quantity is positive' do
      it 'updates the product on facebook catalog' do
        allow(set_fb_products).to receive(:update_inventory)
          .and_return('Successfully updated')
        allow(Facebook::Products).to receive(:new).with(product.retailer)
          .and_return(set_fb_products)

        product.update(facebook_product_id: '123456789')
        expect(product.send(:update_facebook_inventory)).to eq 'Successfully updated'
      end
    end

    context 'when the available quantity is not positive' do
      it 'deletes the product on facebook catalog' do
        allow(set_fb_products).to receive(:delete)
          .and_return('Successfully deleted')
        allow(Facebook::Products).to receive(:new).with(product.retailer)
          .and_return(set_fb_products)

        product.update(facebook_product_id: '123456789', available_quantity: 0)
        expect(product.send(:update_facebook_inventory)).to eq 'Successfully deleted'
      end
    end
  end
end
