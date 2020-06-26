require 'rails_helper'

RSpec.describe Order, type: :model do
  subject(:order) { build(:order, customer: customer) }

  let(:retailer) { create(:retailer) }
  let(:meli_retailer) { create(:meli_retailer, retailer: retailer) }
  let(:customer) { create(:customer, retailer: retailer) }

  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(%i[pending success cancelled]) }

    it do
      expect(order).to define_enum_for(:merc_status)
        .with_values(%i[confirmed payment_required payment_in_process partially_paid paid cancelled invalid_order])
        .with_prefix(true)
    end

    it do
      expect(order).to define_enum_for(:feedback_reason)
        .with_values(%i[SELLER_OUT_OF_STOCK SELLER_DIDNT_TRY_TO_CONTACT_BUYER BUYER_NOT_ENOUGH_MONEY BUYER_REGRETS])
    end

    it { is_expected.to define_enum_for(:feedback_rating).with_values(%i[positive negative neutral]) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:customer) }
    it { is_expected.to belong_to(:retailer_user).required(false) }
    it { is_expected.to have_many(:order_items).inverse_of(:order).dependent(:destroy) }
    it { is_expected.to have_many(:products).through(:order_items) }
    it { is_expected.to have_many(:messages) }

    it { is_expected.to accept_nested_attributes_for(:order_items).allow_destroy(true) }
    it { is_expected.to accept_nested_attributes_for(:customer).allow_destroy(false) }
    it { is_expected.to belong_to(:sales_channel).required(false) }
  end

  describe 'validations' do
    it { is_expected.to validate_length_of(:feedback_message).is_at_most(160) }
  end

  describe 'delegates' do
    it { is_expected.to delegate_method(:retailer_id).to(:customer) }
    it { is_expected.to delegate_method(:retailer).to(:customer) }
  end

  describe '.retailer_orders' do
    before do
      order2 = create(:order, :completed, customer: customer)
      create(:order_item, order: order)
      create(:order_item, order: order2)
    end

    context 'when param status is not all' do
      it 'filters the orders by status' do
        expect(described_class.retailer_orders(retailer.id, 'pending').count).to eq(1)
      end
    end

    context 'when param status is all' do
      it 'does not filter the orders by status' do
        expect(described_class.retailer_orders(retailer.id, 'all').count).to eq(2)
      end
    end
  end

  describe '#total' do
    before do
      create_list(:order_item, 2, order: order, quantity: 2, unit_price: 10.5)
    end

    it 'sums sub-total amount of each item of the order' do
      expect(order.total).to eq(42)
    end
  end

  describe '#last_message' do
    before do
      create_list(:message, 5, order: order)
    end

    it 'returns the last message created for the order' do
      expect(order.last_message.created_at).to eq(order.messages.last.created_at)
    end
  end

  describe '#unread_message?' do
    before do
      create_list(:message, 5, order: order)
    end

    it 'returns false when it was already read and true when it has not been read yet' do
      expect(order.unread_message?).to be true
      order.messages.last.update(date_read: Time.now)
      expect(order.unread_message?).to be false
    end
  end

  describe '#last_message_received_date' do
    before do
      create_list(:message, 5, order: order)
    end

    it 'returns the date of creation of the last message of the order' do
      expect(order.last_message_received_date).to eq(order.messages.last.created_at)
    end
  end

  describe '#push_feedback' do
    context 'when the order does not come from ML' do
      it 'does not call the service to ML' do
        expect(order.send(:push_feedback)).to be_nil
      end
    end

    context 'when the order comes from ML' do
      let(:product) { create(:product, retailer: retailer) }
      let(:set_orders_service) { instance_double(MercadoLibre::Orders) }

      before do
        create(:order_item, :from_ml, order: order, product: product)

        allow(set_orders_service).to receive(:push_feedback)
          .and_return('Successfully pushed')
        allow(MercadoLibre::Orders).to receive(:new).with(retailer)
          .and_return(set_orders_service)
      end

      it 'calls the service to ML' do
        order.meli_order_id = '1234567890'
        expect(order.send(:push_feedback)).to eq('Successfully pushed')
      end
    end
  end

  describe '#set_positive_rating' do
    context 'when the order does not come from ML' do
      it 'before save assigns positive value to feedback rating when the order pass to success status' do
        order.status = 'success'
        order.save
        expect(order.feedback_rating).to be_nil
      end
    end

    context 'when the order comes from ML' do
      let(:product) { create(:product, retailer: retailer) }
      let(:set_orders_service) { instance_double(MercadoLibre::Orders) }

      before do
        create(:order_item, :from_ml, order: order, product: product)

        allow(set_orders_service).to receive(:push_feedback)
          .and_return('Successfully pushed')
        allow(MercadoLibre::Orders).to receive(:new).with(retailer)
          .and_return(set_orders_service)
      end

      it 'before save assigns positive value to feedback rating when the order pass to success status' do
        order.meli_order_id = '123456789'
        order.status = 'success'
        order.save
        expect(order.feedback_rating).to eq('positive')
      end
    end
  end

  describe '#update_items' do
    context 'when the item does not have a product variation and status pass from pending
      or success to cancelled' do
      context 'when the item does not come from ML or the product is closed in ML or
        #from_success_to_cancelled? is true' do
        before do
          product = create(:product, retailer: retailer, available_quantity: 10)
          create(:order_item, order: order, product: product, quantity: 3)
        end

        it 'after update updates the available and sold quantity of the product' do
          expect(order.order_items.last.product.available_quantity).to eq(7)
          expect(order.order_items.last.product.sold_quantity).to eq(3)
        end

        context 'when the order pass from pending to success status' do
          it 'does not update the available or sold quantity' do
            order.update(status: 'success')
            expect(order.order_items.last.product.available_quantity).to eq(7)
            expect(order.order_items.last.product.sold_quantity).to eq(3)
          end
        end

        context 'when the order pass from success to cancelled status' do
          it 'updates the available and sold quantity' do
            order.update(status: 'success')
            order.update(status: 'cancelled')
            expect(order.order_items.last.product.available_quantity).to eq(10)
            expect(order.order_items.last.product.sold_quantity).to eq(0)
          end
        end
      end

      context 'when the item comes from ML or the product is not closed in ML or
        #from_success_to_cancelled? is false' do
        before do
          product = create(:product, retailer: retailer, available_quantity: 10)
          create(:order_item, :from_ml, order: order, product: product, quantity: 3)
        end

        it 'after update does not update the available quantity and updates the sold quantity' do
          expect(order.order_items.last.product.available_quantity).to eq(10)
          expect(order.order_items.last.product.sold_quantity).to eq(3)

          order.update(status: 'cancelled')
          expect(order.order_items.last.product.available_quantity).to eq(10)
          expect(order.order_items.last.product.sold_quantity).to eq(0)
        end
      end
    end

    context 'when the item has a product variation and status pass from pending
      or success to cancelled' do
      context 'when the item does not come from ML or the product is closed in ML or
        #from_success_to_cancelled? is true' do
        before do
          product = create(:product, retailer: retailer, available_quantity: 10)
          product_variation = create(:product_variation, product: product)
          product_variation.data['available_quantity'] = 10
          product_variation.data['sold_quantity'] = 0
          create(:order_item, order: order, product: product, product_variation:
            product_variation, quantity: 3)
        end

        it 'after update updates the available and sold quantity of the product variation' do
          expect(order.order_items.last.product_variation.data['available_quantity']).to eq(7)
          expect(order.order_items.last.product_variation.data['sold_quantity']).to eq(3)
        end

        context 'when the order pass from pending to success status' do
          it 'does not update the available or sold quantity' do
            order.update(status: 'success')
            expect(order.order_items.last.product_variation.data['available_quantity']).to eq(7)
            expect(order.order_items.last.product_variation.data['sold_quantity']).to eq(3)
          end
        end

        context 'when the order pass from success to cancelled status' do
          it 'updates the available and sold quantity' do
            order.update(status: 'success')
            order.update(status: 'cancelled')
            expect(order.order_items.last.product_variation.data['available_quantity']).to eq(10)
            expect(order.order_items.last.product_variation.data['sold_quantity']).to eq(0)
          end
        end
      end

      context 'when the item comes from ML or the product is not closed in ML or
        #from_success_to_cancelled? is false' do
        before do
          product = create(:product, retailer: retailer, available_quantity: 10)
          product_variation = create(:product_variation, product: product)
          product_variation.data['available_quantity'] = 10
          product_variation.data['sold_quantity'] = 0
          create(:order_item, :from_ml, order: order, product: product, product_variation:
            product_variation, quantity: 3)
        end

        it 'after update does not update the available quantity and updates the sold quantity' do
          expect(order.order_items.last.product_variation.data['available_quantity']).to eq(10)
          expect(order.order_items.last.product_variation.data['sold_quantity']).to eq(3)

          order.update(status: 'cancelled')
          expect(order.order_items.last.product_variation.data['available_quantity']).to eq(10)
          expect(order.order_items.last.product_variation.data['sold_quantity']).to eq(0)
        end
      end
    end
  end

  describe '#update_ml' do
    context 'when the product of the item is not linked to ML' do
      let(:product) { create(:product, retailer: retailer) }

      it 'does not call the service to ML' do
        expect(order.send(:update_ml, product)).to be_nil
      end
    end

    context 'when the product of the item is linked to ML' do
      let(:product) { create(:product, :from_ml, retailer: retailer) }
      let(:set_products_service) { instance_double(MercadoLibre::Products) }
      let(:set_product_variations_service) { instance_double(MercadoLibre::ProductVariations) }

      before do
        create(:product_variation, product: product)

        allow(set_products_service).to receive(:push_update)
          .with(anything).and_return('Successfully updated')
        allow(MercadoLibre::Products).to receive(:new).with(retailer)
          .and_return(set_products_service)

        allow(set_product_variations_service).to receive(:create_product_variations)
          .with(anything).and_return('Successfully updated')
        allow(MercadoLibre::ProductVariations).to receive(:new).with(retailer)
          .and_return(set_product_variations_service)
      end

      it 'calls the service to ML' do
        expect(order.send(:update_ml, product)).to eq('Successfully updated')
      end
    end
  end

  describe '#p_ml' do
    let(:product) { create(:product, retailer: retailer) }

    it 'returns the instance of the product service for ML' do
      expect(order.send(:p_ml, product)).to be_a MercadoLibre::Products
    end
  end

  describe '#change_available_quantity' do
    context 'when the item of the order does not come from ML' do
      let(:product) { create(:product, meli_status: 'active') }
      let(:order_item) { create(:order_item, order: order) }

      it 'returns true' do
        order.save
        expect(order.send(:change_available_quantity, order_item)).to be true
      end
    end

    context 'when the product of the item is closed in ML' do
      let(:product) { create(:product, meli_status: 'closed') }
      let(:order_item) { create(:order_item, order: order, product: product, from_ml: true) }

      it 'returns true' do
        order.save
        expect(order.send(:change_available_quantity, order_item)).to be true
      end
    end

    context 'when the order pass from success to cancelled' do
      let(:product) { create(:product, meli_status: 'active') }
      let(:order_item) { create(:order_item, order: order, from_ml: true) }

      it 'returns true' do
        order.status = 'success'
        order.save
        order.update(status: 'cancelled')
        expect(order.send(:change_available_quantity, order_item)).to be true
      end
    end
  end

  describe '#from_pending_to_cancelled?' do
    it 'returns true' do
      order.save
      order.update(status: 'cancelled')
      expect(order.send(:from_pending_to_cancelled?)).to be true
    end
  end

  describe '#from_pending_to_success?' do
    it 'returns true' do
      order.save
      order.update(status: 'success')
      expect(order.send(:from_pending_to_success?)).to be true
    end
  end

  describe '#from_success_to_cancelled?' do
    it 'returns true' do
      order.status = 'success'
      order.save
      order.update(status: 'cancelled')
      expect(order.send(:from_success_to_cancelled?)).to be true
    end
  end

  describe '#generate_web_id' do
    it 'generates the web_id field to orders' do
      expect(order.web_id).to be_nil
      order.save
      expect(order.web_id).not_to be_nil
    end
  end

  describe '#to_param' do
    it 'returns the order web_id' do
      order.save
      expect(order.to_param).to eq(order.web_id)
    end
  end
end
