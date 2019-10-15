require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  subject(:order_item) { build(:order_item, product: product, order: order) }

  let(:retailer) { create(:retailer) }
  let(:order) { create(:order) }
  let(:meli_retailer) { create(:meli_retailer, retailer: retailer) }
  let(:product) { create(:product, retailer: retailer, available_quantity: 9, sold_quantity: 0) }
  let(:product_variation) { create(:product_variation, product: product) }

  describe 'associations' do
    it { is_expected.to belong_to(:order).inverse_of(:order_items) }
    it { is_expected.to belong_to(:product) }
    it { is_expected.to belong_to(:product_variation).required(false) }
  end

  describe 'delegates' do
    it { is_expected.to delegate_method(:meli_product_id).to(:product) }
  end

  describe '#subtotal' do
    it 'calculates the item quantity multilplied by unit price' do
      expect(order_item.subtotal).to eq(order_item.quantity * order_item.unit_price)
    end
  end

  describe '#update_order_total' do
    let!(:order_item2) do
      create(:order_item, product: product, order: order, quantity: 1, unit_price: 10)
    end

    it 'after save updates the total amount of the order' do
      order_item.quantity = 2
      order_item.unit_price = 15
      order_item.save
      expect(order_item.order.total_amount).to eq(40)
    end

    it 'after destroy updates the total amount of the order' do
      order_item.quantity = 2
      order_item.unit_price = 15
      order_item.save
      order_item2.destroy
      expect(order_item.order.total_amount).to eq(30)
    end
  end

  describe '#subtract_stock' do
    context 'when the item does not have a product variation associated and the item is created' do
      context 'when the item does not come from ML' do
        it 'after create updates the available and sold quantity of the product' do
          order_item.quantity = 2
          expect(order_item.product.available_quantity).to eq(9)
          order_item.save
          expect(order_item.product.available_quantity).to eq(7)
          expect(order_item.product.sold_quantity).to eq(2)
        end
      end

      context 'when the item comes from ML' do
        it 'after create does not update the available quantity and updates the sold quantity' do
          order_item.quantity = 2
          order_item.from_ml = true
          expect(order_item.product.available_quantity).to eq(9)
          order_item.save
          expect(order_item.product.available_quantity).to eq(9)
          expect(order_item.product.sold_quantity).to eq(2)
        end
      end
    end

    context 'when the item has a product variation associated and the item is created' do
      context 'when the item does not come from ML' do
        it 'after create updates the available and sold quantity of the product variation' do
          product_variation.data['available_quantity'] = 9
          product_variation.data['sold_quantity'] = 0
          product_variation.save
          order_item.product_variation = product_variation
          order_item.quantity = 2

          expect(order_item.product_variation.data['available_quantity']).to eq(9)
          order_item.save
          expect(order_item.product_variation.data['available_quantity']).to eq(7)
          expect(order_item.product_variation.data['sold_quantity']).to eq(2)
        end
      end

      context 'when the item comes from ML' do
        it 'after create does not update the available quantity and updates the sold quantity' do
          product_variation.data['available_quantity'] = 9
          product_variation.data['sold_quantity'] = 0
          product_variation.save
          order_item.product_variation = product_variation
          order_item.quantity = 2
          order_item.from_ml = true

          expect(order_item.product_variation.data['available_quantity']).to eq(9)
          order_item.save
          expect(order_item.product_variation.data['available_quantity']).to eq(9)
          expect(order_item.product_variation.data['sold_quantity']).to eq(2)
        end
      end
    end
  end

  describe '#update_ml_stock' do
    context 'when the item is being created and it comes from ML' do
      it 'after create does not call the updating method to ML' do
        order_item.from_ml = true
        expect(order_item.send(:update_ml_stock, 'create')).to be_nil
      end
    end

    context 'when the product linked to the item does not exist in ML' do
      it 'after create does not call the updating method to ML' do
        expect(order_item.send(:update_ml_stock)).to be_nil
      end
    end

    context 'when the product linked to the item exists in ML and the item is created or updated locally' do
      let(:set_ml_products) { instance_double(MercadoLibre::Products) }
      let(:p_ml) { instance_double(MercadoLibre::ProductVariations) }

      before do
        allow(set_ml_products).to receive(:push_update)
          .with(anything).and_return('Successfully updated')
        allow(MercadoLibre::Products).to receive(:new).with(order_item.product.retailer)
          .and_return(set_ml_products)
        allow(p_ml).to receive(:create_product_variations)
          .with(anything).and_return('Successfully uploaded')
        allow(MercadoLibre::ProductVariations).to receive(:new).with(product.retailer)
          .and_return(p_ml)
      end

      it 'after create or after update calls the updating method to ML' do
        order_item.product.meli_product_id = '-MEC657381404-'
        order_item.product.retailer.meli_retailer = meli_retailer
        expect(order_item.send(:update_ml_stock)).to eq 'Successfully uploaded'
      end
    end
  end

  describe '#adjust_stock' do
    context 'when the item does not have a product variation associated and the item quantity is updated' do
      it 'before update updates the sold quantity of the product' do
        order_item.quantity = 2
        expect(order_item.product.sold_quantity).to eq(0)
        order_item.save
        expect(order_item.product.sold_quantity).to eq(2)

        order_item.quantity = 1
        order_item.save
        expect(order_item.product.sold_quantity).to eq(1)
      end

      it 'before update updates the available quantity of the product' do
        order_item.quantity = 2
        expect(order_item.product.available_quantity).to eq(9)
        order_item.save
        expect(order_item.product.available_quantity).to eq(7)

        order_item.quantity = 1
        order_item.save
        expect(order_item.product.available_quantity).to eq(8)
      end
    end

    context 'when the item has a product variation associated and the item quantity is updated' do
      it 'before update updates the sold quantity of the product variation' do
        product_variation.data['sold_quantity'] = 0
        product_variation.save
        order_item.product_variation = product_variation
        order_item.quantity = 2

        expect(order_item.product_variation.data['sold_quantity']).to eq(0)
        order_item.save
        expect(order_item.product_variation.data['sold_quantity']).to eq(2)

        order_item.quantity = 1
        order_item.save
        expect(order_item.product_variation.data['sold_quantity']).to eq(1)
      end

      it 'before update updates the available quantity of the product variation' do
        product_variation.data['available_quantity'] = 9
        product_variation.save
        order_item.product_variation = product_variation
        order_item.quantity = 2

        expect(order_item.product_variation.data['available_quantity']).to eq(9)
        order_item.save
        expect(order_item.product_variation.data['available_quantity']).to eq(7)

        order_item.quantity = 1
        order_item.save
        expect(order_item.product_variation.data['available_quantity']).to eq(8)
      end
    end
  end

  describe '#replace_stock' do
    context 'when the item does not have a product variation associated and the item is destroyed' do
      it 'before destroy updates the sold quantity of the product' do
        order_item.quantity = 2
        expect(order_item.product.sold_quantity).to eq(0)
        order_item.save
        expect(order_item.product.sold_quantity).to eq(2)

        order_item.destroy
        expect(product.sold_quantity).to eq(0)
      end

      it 'before destroy updates the available quantity of the product' do
        order_item.quantity = 2
        expect(order_item.product.available_quantity).to eq(9)
        order_item.save
        expect(order_item.product.available_quantity).to eq(7)

        order_item.destroy
        expect(product.available_quantity).to eq(9)
      end
    end

    context 'when the item has a product variation associated and the item is destroyed' do
      it 'before destroy updates the sold quantity of the product variation' do
        product_variation.data['sold_quantity'] = 0
        product_variation.save
        order_item.product_variation = product_variation
        order_item.quantity = 2

        expect(order_item.product_variation.data['sold_quantity']).to eq(0)
        order_item.save
        expect(order_item.product_variation.data['sold_quantity']).to eq(2)

        order_item.destroy
        expect(product_variation.data['sold_quantity']).to eq(0)
      end

      it 'before destroy updates the available quantity of the product variation' do
        product_variation.data['available_quantity'] = 9
        product_variation.save
        order_item.product_variation = product_variation
        order_item.quantity = 2

        expect(order_item.product_variation.data['available_quantity']).to eq(9)
        order_item.save
        expect(order_item.product_variation.data['available_quantity']).to eq(7)

        order_item.destroy
        expect(product_variation.data['available_quantity']).to eq(9)
      end
    end
  end
end
