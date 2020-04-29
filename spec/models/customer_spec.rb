require 'rails_helper'

RSpec.describe Customer, type: :model do
  subject(:customer) { create(:customer) }

  describe 'associations' do
    it { is_expected.to have_one(:agent_customer) }
    it { is_expected.to belong_to(:retailer) }
    it { is_expected.to belong_to(:meli_customer).optional }
    it { is_expected.to have_many(:orders).dependent(:destroy) }
    it { is_expected.to have_many(:questions).dependent(:destroy) }
    it { is_expected.to have_many(:messages).dependent(:destroy) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:id_type).with_values(%i[cedula pasaporte ruc]) }
  end

  describe 'validations' do
    it { is_expected.to allow_value('email@addresse.foo').for(:email) }
    it { is_expected.to allow_value('', nil).for(:email) }
  end

  describe '#earnings' do
    let!(:order) { create(:order, :completed, customer: customer) }
    let!(:order_items) { create_list(:order_item, 5, order: order, product: product, unit_price: 5, quantity: 5) }
    let(:product) { create(:product) }

    it 'returns the retailer earnings for this customer' do
      expect(customer.earnings).to eq 125.0
    end
  end

  describe '#generate_phone' do
    it 'returns nil if customer has phone and its meli_customer has phone' do
      expect(customer.generate_phone).to be_nil
    end

    context 'without phone' do
      subject(:customer) { create(:customer, phone: nil) }

      let!(:meli_customer) { create(:meli_customer, phone: '7378340', customers: [customer]) }

      it 'generates the phone number from ML' do
        customer.generate_phone
        expect(customer.phone).to eq '0987378340'
      end

      context 'when phone area does not start with 0' do
        it 'generates the phone number from ML' do
          meli_customer.update(phone_area: '98')
          customer.generate_phone
          expect(customer.phone).to eq '0987378340'
        end
      end
    end
  end

  describe '#sort_by_completed_orders' do
    let(:retailer) { create(:retailer) }
    let(:customer1) { create(:customer, retailer: retailer) }
    let(:customer2) { create(:customer, retailer: retailer) }
    let!(:order1) { create(:order, customer: customer1, total_amount: 100, status: 'pending') }
    let!(:order2) { create(:order, customer: customer2, total_amount: 200, status: 'success') }

    context 'when the order is ascending' do
      it 'returns the customer with less completed orders first' do
        params = { q: { s: 'sort_by_completed_orders asc' } }
        result = retailer.customers.ransack(params[:q]).result
        expect(result.first).to eq(order1.customer)
      end
    end

    context 'when the order is descending' do
      it 'returns the customer with more completed orders first' do
        params = { q: { s: 'sort_by_completed_orders desc' } }
        result = retailer.customers.ransack(params[:q]).result
        expect(result.first).to eq(order2.customer)
      end
    end
  end

  describe '#sort_by_pending_orders' do
    let(:retailer) { create(:retailer) }
    let(:customer1) { create(:customer, retailer: retailer) }
    let(:customer2) { create(:customer, retailer: retailer) }
    let!(:order1) { create(:order, customer: customer1, total_amount: 100, status: 'success') }
    let!(:order2) { create(:order, customer: customer2, total_amount: 200, status: 'pending') }

    context 'when the order is ascending' do
      it 'returns the customer with less pending orders first' do
        params = { q: { s: 'sort_by_pending_orders asc' } }
        result = retailer.customers.ransack(params[:q]).result
        expect(result.first).to eq(order1.customer)
      end
    end

    context 'when the order is descending' do
      it 'returns the customer with more pending orders first' do
        params = { q: { s: 'sort_by_pending_orders desc' } }
        result = retailer.customers.ransack(params[:q]).result
        expect(result.first).to eq(order2.customer)
      end
    end
  end

  describe '#sort_by_canceled_orders' do
    let(:retailer) { create(:retailer) }
    let(:customer1) { create(:customer, retailer: retailer) }
    let(:customer2) { create(:customer, retailer: retailer) }
    let!(:order1) { create(:order, customer: customer1, total_amount: 100, status: 'pending') }
    let!(:order2) { create(:order, customer: customer2, total_amount: 200, status: 'cancelled') }

    context 'when the order is ascending' do
      it 'returns the customer with less cancelled orders first' do
        params = { q: { s: 'sort_by_canceled_orders asc' } }
        result = retailer.customers.ransack(params[:q]).result
        expect(result.first).to eq(order1.customer)
      end
    end

    context 'when the order is descending' do
      it 'returns the customer with more cancelled orders first' do
        params = { q: { s: 'sort_by_canceled_orders desc' } }
        result = retailer.customers.ransack(params[:q]).result
        expect(result.first).to eq(order2.customer)
      end
    end
  end

  describe '#sort_by_total' do
    let(:retailer) { create(:retailer) }
    let(:customer1) { create(:customer, retailer: retailer) }
    let(:customer2) { create(:customer, retailer: retailer) }
    let!(:order1) { create(:order, customer: customer1, total_amount: 100, status: 'success') }
    let!(:order2) { create(:order, customer: customer2, total_amount: 200, status: 'success') }

    context 'when the order is ascending' do
      it 'returns the customer with less profit first' do
        params = { q: { s: 'sort_by_total asc' } }
        result = retailer.customers.ransack(params[:q]).result
        expect(result.first).to eq(order1.customer)
      end
    end

    context 'when the order is descending' do
      it 'returns the customer with more profit first' do
        params = { q: { s: 'sort_by_total desc' } }
        result = retailer.customers.ransack(params[:q]).result
        expect(result.first).to eq(order2.customer)
      end
    end
  end

  describe '#range_earnings' do
    let(:order) { create(:order, customer: customer, status: 'success') }
    let!(:order_item) { create(:order_item, order: order, quantity: 3, unit_price: 25) }

    it 'returns the profit from the customer of bought products' do
      start_date = 1.day.ago
      end_date = Time.now
      expect(customer.range_earnings(start_date, end_date)).to eq(75)
    end
  end

  describe '#range_items_bought' do
    let(:order) { create(:order, customer: customer, status: 'success') }
    let!(:order_item) { create(:order_item, order: order, quantity: 3, unit_price: 25) }

    it 'returns the quantity of items the customer has bought' do
      start_date = 1.day.ago
      end_date = Time.now
      expect(customer.range_items_bought(start_date, end_date)).to eq(3)
    end
  end

  describe '#generate_web_id' do
    let(:customer) { build(:customer) }

    it 'generates the web_id field to customers' do
      expect(customer.web_id).to be_nil
      customer.save
      expect(customer.web_id).not_to be_nil
    end
  end

  describe '#to_param' do
    it 'returns the customer web_id' do
      expect(customer.to_param).to eq(customer.web_id)
    end
  end

  describe '#assigned_agent' do
    context 'when the customer is assigned to an agent' do
      let(:retailer_user) { create(:retailer_user, :with_retailer) }
      let(:agent_customer) { create(:agent_customer, retailer_user: retailer_user, customer: subject) }

      let(:response) do
        {
          id: agent_customer.retailer_user.id,
          full_name: agent_customer.retailer_user.full_name,
          email: agent_customer.retailer_user.email
        }
      end

      it 'returns the agent information' do
        expect(agent_customer.customer.assigned_agent).to eq(response)
      end
    end

    context 'when the customer is not assigned to an agent' do
      let(:response) do
        {
          id: '',
          full_name: '',
          email: ''
        }
      end

      it 'returns an empty object' do
        expect(customer.assigned_agent).to eq(response)
      end
    end
  end

  describe '#recent_karix_message_date' do
    let(:customer) { create(:customer) }
    let!(:message1) { create(:karix_whatsapp_message, customer: customer, created_time: Time.now) }
    let!(:message2) { create(:karix_whatsapp_message, customer: customer, created_time: Time.now) }
    let!(:message3) { create(:karix_whatsapp_message, customer: customer, created_time: Time.now) }

    it 'returns the creation date of the last message' do
      expect(customer.recent_karix_message_date).to eq(message3.created_time)
    end
  end

  describe '#recent_facebook_message_date' do
    let(:customer) { create(:customer) }
    let!(:message1) { create(:facebook_message, customer: customer) }
    let!(:message2) { create(:facebook_message, customer: customer) }
    let!(:message3) { create(:facebook_message, customer: customer) }

    it 'returns the creation date of the last message' do
      expect(customer.recent_facebook_message_date).to eq(message3.created_at)
    end
  end
end
