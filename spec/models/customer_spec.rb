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

  describe '#recent_inbound_message_date' do
    before do
      travel_to Time.now
    end

    context 'when karix integrated' do
      let(:customer) { create(:customer, :with_retailer_karix_integrated) }
      let!(:message1) { create(:karix_whatsapp_message, :inbound, customer: customer, created_time: Time.now) }
      let!(:message2) { create(:karix_whatsapp_message, :inbound, customer: customer, created_time: Time.now) }
      let!(:message3) { create(:karix_whatsapp_message, :inbound, customer: customer, created_time: Time.now) }

      it 'returns the creation date of the last message' do
        expect(customer.recent_inbound_message_date).to eq(message3.created_time)
      end
    end

    context 'when gupshup integrated' do
      let(:customer) { create(:customer, :with_retailer_gupshup_integrated) }
      let!(:message1) { create(:gupshup_whatsapp_message, :inbound, customer: customer, created_at: Time.now) }
      let!(:message2) { create(:gupshup_whatsapp_message, :inbound, customer: customer, created_at: Time.now) }
      let!(:message3) { create(:gupshup_whatsapp_message, :inbound, customer: customer, created_at: Time.now) }

      it 'returns the creation date of the last message' do
        expect(customer.recent_inbound_message_date).to eq(message3.created_at)
      end
    end

    after do
      travel_back
    end
  end

  describe '#recent_facebook_message_date' do
    let(:customer) { create(:customer) }
    let!(:message1) { create(:facebook_message, customer: customer) }
    let!(:message2) { create(:facebook_message, customer: customer) }
    let!(:message3) { create(:facebook_message, customer: customer) }

    it 'returns the creation date of the last message' do
      expect(customer.recent_facebook_message_date).to eq(customer.facebook_messages.last.created_at)
    end
  end

  describe '#emoji_flag' do
    let(:customer) { create(:customer, country_id: nil) }

    context 'when the country is not set' do
      it 'returns nil' do
        expect(customer.emoji_flag).to be nil
      end
    end

    context 'when the country is set' do
      it 'returns the flag emoji' do
        customer.update_column(:country_id, 'EC')
        c = ISO3166::Country.new(customer.country_id)
        expect(customer.emoji_flag).to eq(c.emoji_flag)
      end
    end
  end

  describe '#country' do
    let(:customer) { create(:customer, country_id: nil) }

    context 'when the country is not set' do
      it 'returns nil' do
        expect(customer.country).to be nil
      end
    end

    context 'when the country is set' do
      it 'returns a country instance' do
        customer.update_column(:country_id, 'EC')
        expect(customer.country).to be_instance_of(ISO3166::Country)
      end
    end
  end

  describe '#format_phone_number' do
    let(:customer) { create(:customer, country_id: nil) }

    it 'returns nil unless country and phone are present' do
      expect(customer.send(:format_phone_number)).to be nil
    end

    it 'gives format to the phone' do
      customer.country_id = 'EC'
      customer.phone = '123456789'
      expect(customer.send(:format_phone_number)).to eq('+593123456789')
    end
  end

  describe '#split_phone' do
    context 'when the phone is not present' do
      it 'returns nil' do
        subject.phone = nil
        expect(subject.split_phone).to be nil
      end
    end

    context 'when the phone is correct' do
      it 'returns an array with the number parsed' do
        subject.phone = '+593123456789'
        expect(subject.split_phone).to be_instance_of(Array)
        expect(subject.split_phone[0]).to eq('593')
      end
    end

    context 'when the phone is not correct' do
      it 'returns nil' do
        subject.phone = '0923456789'
        expect(subject.split_phone).to be nil
      end
    end
  end

  describe '#total_whatsapp_messages' do
    context 'when the retailer is integrated with Karix' do
      let(:retailer) { create(:retailer, :karix_integrated) }
      let(:customer_karix) { create(:customer, retailer: retailer) }

      before do
        create_list(:karix_whatsapp_message, 2, customer: customer_karix)
      end

      it 'counts the messages on Karix Whatsapp Messages table' do
        expect(customer_karix.total_whatsapp_messages).to eq(2)
      end
    end

    context 'when the retailer is integrated with Gupshup' do
      let(:retailer) { create(:retailer, :gupshup_integrated) }
      let(:customer_gupshup) { create(:customer, retailer: retailer) }

      before do
        create_list(:gupshup_whatsapp_message, 3, customer: customer_gupshup)
      end

      it 'counts the messages on Gupshup Whatsapp Messages table' do
        expect(customer_gupshup.total_whatsapp_messages).to eq(3)
      end
    end
  end

  describe '#total_messenger_messages' do
    let(:facebook_retailer) { create(:facebook_retailer) }
    let(:customer) { create(:customer, retailer: facebook_retailer.retailer) }

    before do
      create_list(:facebook_message, 5, customer: customer)
    end

    it 'counts the facebook messages of the customer' do
      expect(customer.total_messenger_messages).to eq(5)
    end
  end

  describe '#before_last_whatsapp_message' do
    context 'when there are not at least two whatsapp messages' do
      let(:retailer) { create(:retailer, :karix_integrated) }
      let(:customer) { create(:customer, retailer: retailer) }
      let!(:whatsapp_message) { create(:karix_whatsapp_message, :inbound, customer: customer) }

      it 'returns nil' do
        expect(customer.before_last_whatsapp_message). to be nil
      end
    end

    context 'when retailer is Karix integrated' do
      let(:retailer) { create(:retailer, :karix_integrated) }
      let(:customer_karix) { create(:customer, retailer: retailer) }

      before do
        create_list(:karix_whatsapp_message, 2, :inbound, customer: customer_karix)
      end

      it 'returns the message before the last one' do
        expect(customer_karix.before_last_whatsapp_message).to eq(KarixWhatsappMessage.last(2).first)
      end
    end

    context 'when retailer is Gupshup integrated' do
      let(:retailer) { create(:retailer, :gupshup_integrated) }
      let(:customer_gupshup) { create(:customer, retailer: retailer) }

      before do
        create_list(:gupshup_whatsapp_message, 2, :inbound, customer: customer_gupshup)
      end

      it 'returns the message before the last one' do
        expect(customer_gupshup.before_last_whatsapp_message).to eq(GupshupWhatsappMessage.last(2).first)
      end
    end
  end

  describe '#before_last_messenger_message' do
    context 'when there are not at least two facebook messages' do
      let(:facebook_retailer) { create(:facebook_retailer) }
      let(:customer) { create(:customer, retailer: facebook_retailer.retailer) }
      let!(:facebook_message) { create(:facebook_message, customer: customer, sent_by_retailer: false) }

      it 'returns nil' do
        expect(customer.before_last_messenger_message). to be nil
      end
    end

    context 'when there are at least two facebook messages' do
      let(:facebook_retailer) { create(:facebook_retailer) }
      let(:customer) { create(:customer, retailer: facebook_retailer.retailer) }

      before do
        create_list(:facebook_message, 2, customer: customer, sent_by_retailer: false)
      end

      it 'returns the message before the last one' do
        expect(customer.before_last_messenger_message).to eq(FacebookMessage.last(2).first)
      end
    end
  end
end
