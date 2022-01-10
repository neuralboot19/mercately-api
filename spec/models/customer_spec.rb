require 'rails_helper'

RSpec.describe Customer, type: :model do
  let!(:retailer) { create(:retailer) }
  subject(:customer) { create(:customer, retailer: retailer) }

  before do
    allow_any_instance_of(Exponent::Push::Client).to receive(:send_messages).and_return(true)
  end

  describe 'associations' do
    it { is_expected.to have_one(:agent_customer) }
    it { is_expected.to belong_to(:retailer) }
    it { is_expected.to belong_to(:meli_customer).optional }
    it { is_expected.to have_many(:orders).dependent(:destroy) }
    it { is_expected.to have_many(:questions).dependent(:destroy) }
    it { is_expected.to have_many(:messages).dependent(:destroy) }
    it { is_expected.to have_many(:customer_tags).dependent(:destroy) }
    it { is_expected.to have_many(:tags).through(:customer_tags) }
    it { is_expected.to have_one(:chat_bot).through(:chat_bot_option) }
    it { is_expected.to have_many(:chat_histories).dependent(:destroy) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:id_type).with_values(%i[cedula pasaporte ruc rut otro]) }
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
    let(:customer) { create(:customer, :messenger) }
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

  describe '#phone_uniqueness' do
    let(:customer) { create(:customer, country_id: nil, phone: '+593664-269-163', retailer: retailer) }

    it 'returns nil if retailer not present' do
      expect(customer.send(:phone_uniqueness)).to be nil
    end

    it 'returns nil if email present and phone blank' do
      customer.phone = ''
      customer.email = 'someemail.com'
      customer.save

      expect(customer.send(:phone_uniqueness)).to be nil
    end

    it 'not valid if retailer has another client with the same phone' do
      customer
      customer2 = build(:customer, phone: '+593664-269-163', retailer: retailer)
      expect(customer2.valid?).to eq(false)
      expect(customer2.errors[:base]).to include('Ya tienes un cliente registrado con este número de teléfono.')
    end

    it 'returns true if is a ML customer' do
      customer2 = build(:customer,
                        phone: customer.phone,
                        retailer: retailer,
                        meli_customer_id: 42141421423,
                        meli_nickname: 'awesomw_NiCKnaMe'
                       )

      expect(customer2.valid?).to eq(true)
    end

    it 'returns false if is not a ML customer' do
      customer2 = build(:customer,
                        phone: customer.phone,
                        retailer: retailer
                       )

      expect(customer2.valid?).to eq(false)
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

  describe '#whatsapp_messages' do
    context 'when the retailer is Karix integrated' do
      let(:retailer) { create(:retailer, :karix_integrated) }
      let(:customer_karix) { create(:customer, retailer: retailer) }

      before do
        create_list(:karix_whatsapp_message, 2, customer: customer_karix)
      end

      it 'counts the messages on Karix Whatsapp Messages table' do
        expect(customer_karix.whatsapp_messages.count).to eq(2)
      end
    end

    context 'when the retailer is Gupshup integrated' do
      let(:retailer) { create(:retailer, :gupshup_integrated) }
      let(:customer_gupshup) { create(:customer, retailer: retailer) }

      before do
        create_list(:gupshup_whatsapp_message, 3, customer: customer_gupshup)
      end

      it 'counts the messages on Gupshup Whatsapp Messages table' do
        expect(customer_gupshup.whatsapp_messages.count).to eq(3)
      end
    end
  end

  describe '#total_messenger_messages' do
    let(:facebook_retailer) { create(:facebook_retailer) }
    let(:customer) { create(:customer, :messenger, retailer: facebook_retailer.retailer) }

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
      let(:customer) { create(:customer, :messenger, retailer: facebook_retailer.retailer) }
      let!(:facebook_message) { create(:facebook_message, customer: customer, sent_by_retailer: false) }

      it 'returns nil' do
        expect(customer.before_last_messenger_message). to be nil
      end
    end

    context 'when there are at least two facebook messages' do
      let(:facebook_retailer) { create(:facebook_retailer) }
      let(:customer) { create(:customer, :messenger, retailer: facebook_retailer.retailer) }

      before do
        create_list(:facebook_message, 2, customer: customer, sent_by_retailer: false)
      end

      it 'returns the message before the last one' do
        expect(customer.before_last_messenger_message).to eq(FacebookMessage.last(2).first)
      end
    end
  end

  describe '#last_messenger_message' do
    let(:facebook_retailer) { create(:facebook_retailer) }
    let(:customer) { create(:customer, :messenger, retailer: facebook_retailer.retailer) }

    before do
      create_list(:facebook_message, 2, customer: customer)
    end

    it 'returns the last messenger message' do
      expect(customer.last_messenger_message).to eq(FacebookMessage.last)
    end
  end

  describe '#accept_opt_in!' do
    let(:retailer) { create(:retailer, :gupshup_integrated) }
    let(:customer) { create(:customer, retailer: retailer, whatsapp_opt_in: false) }
    let(:service_response) {
      { :code=>"202" }
    }

    before do
      allow_any_instance_of(Whatsapp::Gupshup::V1::Outbound::Users).to receive(:opt_in).and_return(service_response)
    end

    it 'updates whatsapp_opt_in for a gupshup integrated retailer' do
      customer.send_for_opt_in = true
      customer.accept_opt_in!
      expect(customer.reload.whatsapp_opt_in).to be(true)
    end
  end

  describe '#verify_new_phone' do
    describe 'when karix integrated' do
      let(:customer) { create(:customer, :with_retailer_karix_integrated, whatsapp_opt_in: nil) }

      describe 'when NOT updates the phone' do
        it 'not changes whatsapp_opt_in' do
          former_ws_opt_in = customer.whatsapp_opt_in

          customer.first_name = 'Firstname'
          customer.save!

          expect(customer.reload.whatsapp_opt_in).to eq(former_ws_opt_in)
        end
      end

      describe 'when updates the phone' do
        it 'not changes whatsapp_opt_in' do
          former_ws_opt_in = customer.whatsapp_opt_in

          customer.phone = '+5939898989898'
          customer.save!

          expect(customer.reload.whatsapp_opt_in).to eq(former_ws_opt_in)
        end
      end
    end

    describe 'when gupshup integrated' do
      let(:customer) { create(:customer, :with_retailer_gupshup_integrated) }

      context 'and NOT updates the phone' do
        it 'does not change send_for_opt_in' do
          customer.update(first_name: 'Firstname')

          expect(customer.reload.send_for_opt_in).to eq(nil)
        end
      end

      context 'when the previous phone was not verified' do
        context 'and send_for_opt_in is not checked' do
          it 'does not proceed with the verification' do
            customer.update(phone: '+5939898989898')

            expect(customer.reload.send_for_opt_in).to be nil
            expect(customer.reload.whatsapp_opt_in).to be false
          end
        end
      end

      context 'and updates the phone' do
        before do
          allow_any_instance_of(Customer).to receive(:verify_opt_in).and_return(true)
        end

        it 'sets send_for_opt_in to true and whatsapp_opt_in to false' do
          # So it can be opt-in verified in the verify_opt_in method
          customer.update(phone: '+5939898989898', whatsapp_opt_in: true)

          expect(customer.reload.send_for_opt_in).to eq(true)
          expect(customer.reload.whatsapp_opt_in).to eq(false)
        end
      end
    end
  end

  describe '#handle_message_events?' do
    describe 'when karix integrated' do
      let(:customer) { create(:customer, :with_retailer_karix_integrated) }

      it 'returns true' do
        expect(customer.handle_message_events?).to eq(true)
      end
    end

    describe 'when gupshup integrated' do
      let(:customer) { create(:customer, :with_retailer_gupshup_integrated) }

      it 'returns true' do
        expect(customer.handle_message_events?).to eq(true)
      end
    end

    describe 'when not integrated with any whatsapp provider' do
      let(:customer) { create(:customer) }

      it 'returns false' do
        expect(customer.handle_message_events?).to eq(false)
      end
    end
  end

  describe '#whatsapp_answered_by_agent?' do
    let(:retailer) { create(:retailer, :gupshup_integrated) }
    let(:retailer_user) { create(:retailer_user, retailer: retailer) }
    let(:customer) { create(:customer, retailer: retailer) }
    let!(:inbound_message) do
      create(:gupshup_whatsapp_message, :inbound, customer: customer, retailer: retailer)
    end

    context 'when there is at least an outbound message from agent' do
      let!(:outbound_message) do
        create(:gupshup_whatsapp_message, :outbound, customer: customer, retailer: retailer, retailer_user:
          retailer_user)
      end

      it 'returns true' do
        expect(customer.whatsapp_answered_by_agent?).to be true
      end
    end

    context 'when there is at least an outbound message but not from agent' do
      let!(:outbound_message) do
        create(:gupshup_whatsapp_message, :outbound, customer: customer, retailer: retailer)
      end

      it 'returns true' do
        expect(customer.whatsapp_answered_by_agent?).to be false
      end
    end

    context 'when there is not any outbound message' do
      it 'returns true' do
        expect(customer.whatsapp_answered_by_agent?).to be false
      end
    end
  end

  describe '#first_whatsapp_answer_by_agent?' do
    describe 'GupShup integrated' do
      let(:retailer) { create(:retailer, :gupshup_integrated) }
      let(:retailer_user) { create(:retailer_user, retailer: retailer) }
      let(:customer) { create(:customer, retailer: retailer) }
      let!(:inbound_message) do
        create(:gupshup_whatsapp_message, :inbound, customer: customer, retailer: retailer)
      end

      let(:outbound_message) do
        create(:gupshup_whatsapp_message, :outbound, customer: customer, retailer: retailer, retailer_user:
          retailer_user)
      end

      context 'when there are more than one message sent to the customer' do
        let!(:other_outbound_message) do
          create(:gupshup_whatsapp_message, :outbound, customer: customer, retailer: retailer, retailer_user:
            retailer_user)
        end

        it 'returns false' do
          expect(customer.first_whatsapp_answer_by_agent?(outbound_message.gupshup_message_id)).to be false
        end
      end

      context 'when there is one outbound message from agent' do
        context 'with the message id equal to the passed in parameters' do
          it 'returns true' do
            expect(customer.first_whatsapp_answer_by_agent?(outbound_message.gupshup_message_id)).to be true
          end
        end

        context 'with the message id not equal to the passed in parameters' do
          it 'returns false' do
            outbound_message
            expect(customer.first_whatsapp_answer_by_agent?('Anything')).to be false
          end
        end
      end

      context 'when there are not messages sent from agent' do
        let(:not_agent_message) do
          create(:gupshup_whatsapp_message, :outbound, customer: customer, retailer: retailer)
        end

        it 'returns true' do
          expect(customer.first_whatsapp_answer_by_agent?(not_agent_message.gupshup_message_id)).to be true
        end
      end
    end

    describe 'Karix integrated' do
      let(:retailer) { create(:retailer, :karix_integrated) }
      let(:retailer_user) { create(:retailer_user, retailer: retailer) }
      let(:customer) { create(:customer, retailer: retailer) }
      let!(:inbound_message) do
        create(:karix_whatsapp_message, :inbound, customer: customer, retailer: retailer)
      end

      let(:outbound_message) do
        create(:karix_whatsapp_message, :outbound, customer: customer, retailer: retailer, retailer_user:
          retailer_user)
      end

      context 'when there are more than one message sent to the customer' do
        let!(:other_outbound_message) do
          create(:karix_whatsapp_message, :outbound, customer: customer, retailer: retailer, retailer_user:
            retailer_user)
        end

        it 'returns false' do
          expect(customer.first_whatsapp_answer_by_agent?(outbound_message.uid)).to be false
        end
      end

      context 'when there is one outbound message from agent' do
        context 'with the message id equal to the passed in parameters' do
          it 'returns true' do
            expect(customer.first_whatsapp_answer_by_agent?(outbound_message.uid)).to be true
          end
        end

        context 'with the message id not equal to the passed in parameters' do
          it 'returns false' do
            outbound_message
            expect(customer.first_whatsapp_answer_by_agent?('Anything')).to be false
          end
        end
      end

      context 'when there are not messages sent from agent' do
        let(:not_agent_message) do
          create(:karix_whatsapp_message, :outbound, customer: customer, retailer: retailer)
        end

        it 'returns true' do
          expect(customer.first_whatsapp_answer_by_agent?(not_agent_message.uid)).to be true
        end
      end
    end
  end

  describe '#messenger_answered_by_agent?' do
    let(:retailer) { create(:retailer) }
    let(:facebook_retailer) { create(:facebook_retailer, retailer: retailer) }
    let(:retailer_user) { create(:retailer_user, retailer: retailer) }
    let(:customer) { create(:customer, :messenger, retailer: retailer) }
    let!(:inbound_message) do
      create(:facebook_message, :inbound, customer: customer, facebook_retailer: facebook_retailer)
    end

    context 'when there is at least an outbound message from agent' do
      let!(:outbound_message) do
        create(:facebook_message, :outbound, customer: customer, facebook_retailer: facebook_retailer,
          retailer_user: retailer_user)
      end

      it 'returns true' do
        expect(customer.messenger_answered_by_agent?).to be true
      end
    end

    context 'when there is at least an outbound message but not from agent' do
      let!(:outbound_message) do
        create(:facebook_message, :outbound, customer: customer, facebook_retailer: facebook_retailer)
      end

      it 'returns true' do
        expect(customer.messenger_answered_by_agent?).to be false
      end
    end

    context 'when there is not any outbound message' do
      it 'returns true' do
        expect(customer.messenger_answered_by_agent?).to be false
      end
    end
  end

  describe '#first_messenger_answer_by_agent?' do
    let(:retailer) { create(:retailer) }
    let(:facebook_retailer) { create(:facebook_retailer, retailer: retailer) }
    let(:retailer_user) { create(:retailer_user, retailer: retailer) }
    let(:customer) { create(:customer, :messenger, retailer: retailer) }
    let!(:inbound_message) do
      create(:facebook_message, :inbound, customer: customer, facebook_retailer: facebook_retailer)
    end

    let(:outbound_message) do
      create(:facebook_message, :outbound, customer: customer, facebook_retailer: facebook_retailer,
        retailer_user: retailer_user)
    end

    context 'when there are more than one message sent to the customer' do
      let!(:other_outbound_message) do
        create(:facebook_message, :outbound, customer: customer, facebook_retailer: facebook_retailer,
          retailer_user: retailer_user)
      end

      it 'returns false' do
        expect(customer.first_messenger_answer_by_agent?(outbound_message.mid)).to be false
      end
    end

    context 'when there is one outbound message from agent' do
      context 'with the message id equal to the passed in parameters' do
        it 'returns true' do
          expect(customer.first_messenger_answer_by_agent?(outbound_message.mid)).to be true
        end
      end

      context 'with the message id not equal to the passed in parameters' do
        it 'returns false' do
          outbound_message
          expect(customer.first_messenger_answer_by_agent?('Anything')).to be false
        end
      end
    end

    context 'when there are not messages sent from agent' do
      let(:not_agent_message) do
        create(:facebook_message, :outbound, customer: customer, facebook_retailer: facebook_retailer)
      end

      it 'returns true' do
        expect(customer.first_messenger_answer_by_agent?(not_agent_message.mid)).to be true
      end
    end
  end

  describe '#notification_info' do
    context 'when it has first name and/or last name' do
      let(:customer) { create(:customer, first_name: 'Test', last_name: 'Test') }

      it 'returns the full name' do
        expect(customer.notification_info).to eq('Test Test')
      end
    end

    context 'when it has whatsapp name' do
      let(:customer) { create(:customer, first_name: nil, last_name: nil, whatsapp_name: 'Nickname') }

      it 'returns the whatsapp name' do
        expect(customer.notification_info).to eq('Nickname')
      end
    end

    context 'when it only has phone number' do
      let(:customer) { create(:customer, first_name: nil, last_name: nil, whatsapp_name: nil, phone: '+593987654321') }

      it 'returns the phone number' do
        expect(customer.notification_info).to eq(customer.phone)
      end
    end
  end

  describe '#unread_messenger_messages' do
    let(:customer) { create(:customer, :messenger) }

    before do
      create_list(:facebook_message, 2, :inbound, customer: customer)
      create_list(:facebook_message, 3, :inbound, customer: customer)
    end

    it 'returns the total unread inbound messenger messages' do
      expect(customer.unread_messenger_messages).to eq(5)
    end
  end

  describe '#deactivate_chat_bot!' do
    let(:customer) { create(:customer, :bot_active, retailer: retailer) }

    it 'deactivates the current bot the customer has active' do
      expect(customer.active_bot).to be true
      customer.deactivate_chat_bot!
      expect(customer.active_bot).to be false
    end
  end

  describe '#activate_chat_bot!' do
    context 'when the customer is not allowed to get already used chat bots activated' do
      let(:customer) { create(:customer, retailer: retailer, allow_start_bots: false) }

      it 'allows it' do
        expect(customer.allow_start_bots).to be false
        customer.activate_chat_bot!
        expect(customer.allow_start_bots).to be true
      end
    end

    context 'when the customer is allowed to get already used chat bots activated' do
      let(:customer) { create(:customer, retailer: retailer, allow_start_bots: true) }

      it 'does not allow it' do
        expect(customer.allow_start_bots).to be true
        customer.activate_chat_bot!
        expect(customer.allow_start_bots).to be false
      end
    end
  end

  describe '#grab_country_on_import' do
    context 'when phone is not present' do
      let(:customer) { create(:customer, phone: nil) }

      it 'returns nil' do
        expect(customer.send(:grab_country_on_import)).to be_nil
      end
    end

    context 'when country_id is not blank' do
      let(:customer) { create(:customer, phone: '123456789', country_id: 'EC') }

      it 'returns nil' do
        expect(customer.send(:grab_country_on_import)).to be_nil
      end
    end

    context 'when country_id is blank and phone is present' do
      context 'when phone is well formatted' do
        let(:customer) { create(:customer, phone: '584141234567', country_id: nil) }

        it 'sets the country_id to the customer' do
          expect(customer.country_id).to be_nil
          customer.send(:grab_country_on_import)
          expect(customer.country_id).to eq('VE')
        end
      end

      context 'when phone is not well formatted' do
        let(:customer) { create(:customer, phone: '04141234567', country_id: nil) }

        it 'sets the country_id to the customer' do
          expect(customer.country_id).to be_nil
          customer.send(:grab_country_on_import)
          expect(customer.country_id).to be_nil
        end
      end
    end
  end

  describe '#sync_hs' do
    let(:retailer_user) { create(:retailer_user, :admin, :with_retailer) }
    let(:retailer) { retailer_user.retailer }
    let(:customer) { create(:customer, retailer: retailer, hs_active: true) }
    let(:contact_response) do
      {
        'id'=>'101',
        'properties'=>{
          'createdate'=>'2021-02-01T20:01:01.058Z',
          'email'=>'dortin42@gmail.com',
          'firstname'=>'Daniel',
          'hs_object_id'=>'101',
          'lastmodifieddate'=>'2021-02-03T02:02:23.777Z',
          'lastname'=>'Ortin'
        },
        'createdAt'=>'2021-02-01T20:01:01.058Z',
        'updatedAt'=>'2021-02-03T02:02:23.777Z',
        'archived'=>false
      }
    end
    let(:contact_properties_response) do
      [
        {"name"=>"company_size", "label"=>"Company size", "type"=>"string", "fieldType"=>"text", "groupName"=>"facebook_ads_properties", "options"=>[], "displayOrder"=>-1, "calculated"=>false, "externalOptions"=>false, "hasUniqueValue"=>false, "hidden"=>false, "formField"=>true},
        {"name"=>"date_of_birth", "label"=>"Date of birth", "type"=>"string", "fieldType"=>"text", "groupName"=>"facebook_ads_properties", "options"=>[], "displayOrder"=>-1, "calculated"=>false, "externalOptions"=>false, "hasUniqueValue"=>false, "hidden"=>false, "formField"=>true},
        {"name"=>"days_to_close", "label"=>"Days To Close", "type"=>"number", "fieldType"=>"number", "groupName"=>"deal_information", "options"=>[], "displayOrder"=>-1, "calculated"=>true, "externalOptions"=>false, "hasUniqueValue"=>false, "hidden"=>false, "formField"=>false},
        {"name"=>"degree", "label"=>"Degree", "type"=>"string", "fieldType"=>"text", "groupName"=>"facebook_ads_properties", "options"=>[], "displayOrder"=>-1, "calculated"=>false, "externalOptions"=>false, "hasUniqueValue"=>false, "hidden"=>false, "formField"=>true},
        {"name"=>"field_of_study", "label"=>"Field of study", "type"=>"string", "fieldType"=>"text", "groupName"=>"facebook_ads_properties", "options"=>[], "displayOrder"=>-1, "calculated"=>false, "externalOptions"=>false, "hasUniqueValue"=>false, "hidden"=>false, "formField"=>true},
        {"name"=>"first_conversion_date", "label"=>"First Conversion Date", "type"=>"datetime", "fieldType"=>"date", "groupName"=>"contact_activity", "options"=>[], "displayOrder"=>-1, "calculated"=>true, "externalOptions"=>false, "hasUniqueValue"=>false, "hidden"=>false, "formField"=>false},
        {"name"=>"first_conversion_event_name", "label"=>"First Conversion", "type"=>"string", "fieldType"=>"text", "groupName"=>"contact_activity", "options"=>[], "displayOrder"=>-1, "calculated"=>true, "externalOptions"=>false, "hasUniqueValue"=>false, "hidden"=>false, "formField"=>false},
        {"name"=>"first_deal_created_date", "label"=>"First Deal Created Date", "type"=>"datetime", "fieldType"=>"date", "groupName"=>"deal_information", "options"=>[], "displayOrder"=>-1, "calculated"=>false, "externalOptions"=>false, "hasUniqueValue"=>false, "hidden"=>false, "formField"=>false}
      ]
    end

    before do
      allow_any_instance_of(HubspotService::Api).to receive(:contact_properties).and_return(contact_properties_response)
      retailer.update(hs_access_token: 'CK3_krf2LhICAQEY_PC4BCDmvqsGKIbQDjIZALypCKWvZcmF-D-RAwomzwIqjQdcwK3NJjoaAAoCQQAADIADAAgAAAABAAAAAAAAABjAABNCGQC8qQileauAqGkAwUfvfK8_0hB97oc77u0')
    end

    context 'when hubspot integrated' do
      it 'gets the hs_id' do
        allow_any_instance_of(HubspotService::Api).to receive(:contact_update).and_return(contact_response)
        allow_any_instance_of(HubspotService::Api).to receive(:search).and_return(contact_response)
        allow_any_instance_of(Net::HTTPOK).to receive(:read_body).and_return(contact_response)
        customer.send :sync_hs
        expect(customer.hs_id).to eq '101'
      end
    end
  end

  describe '#is_chat_open?' do
    context 'when the customer has an inbound message minor to 24 hours' do
      let(:customer) { create(:customer) }
      let!(:inbound_message) do
        create(:gupshup_whatsapp_message, :inbound, :conversation, customer: customer, created_at: Time.now - 10.hours)
      end

      it 'returns true' do
        expect(customer.is_chat_open?).to be true
      end
    end

    context 'when the customer does not have inbound messages' do
      let(:customer) { create(:customer) }

      it 'returns false' do
        expect(customer.is_chat_open?).to be false
      end
    end

    context 'when the customer has an inbound message older than 24 hours' do
      let(:customer) { create(:customer) }
      let!(:inbound_message) do
        create(:gupshup_whatsapp_message, :inbound, :conversation, customer: customer, created_at: Time.now - 30.hours)
      end

      it 'returns false' do
        expect(customer.is_chat_open?).to be false
      end
    end
  end

  describe '#calc_ws_notification_cost' do
    country_codes = JSON.parse(File.read("#{Rails.public_path}/json/all_countries_price.json"))

    context 'when the customer has country' do
      let!(:customer) { create(:customer, phone: '+593123456789', country_id: 'EC') }

      it 'sets the notification cost belonging to that country' do
        expect(customer.ws_notification_cost).to eq(country_codes['EC'][0])
      end

      it 'sets the business conversation cost belonging to that country' do
        expect(customer.ws_bic_cost).to eq(country_codes['EC'][1])
      end

      it 'sets the user conversation cost belonging to that country' do
        expect(customer.ws_uic_cost).to eq(country_codes['EC'][2])
      end
    end

    context 'when the customer does not have country' do
      let!(:customer) { create(:customer, phone: '+593123456789', country_id: nil) }

      it 'sets the default notification cost' do
        expect(customer.ws_notification_cost).to eq(country_codes['Others'][0])
      end

      it 'sets the default business conversation cost' do
        expect(customer.ws_bic_cost).to eq(country_codes['Others'][1])
      end

      it 'sets the default user conversation cost' do
        expect(customer.ws_uic_cost).to eq(country_codes['Others'][2])
      end
    end
  end

  describe '#open_chat' do
    let(:retailer) { create(:retailer) }
    let(:retailer_user) { create(:retailer_user, :admin, retailer: retailer) }

    context 'when the chat is on new_chat status' do
      let(:customer) { create(:customer, retailer: retailer, status_chat: 'new_chat') }

      it 'updates the chat to open_chat status' do
        expect {
          customer.open_chat!(retailer_user)
        }.to change(ChatHistory, :count).by(1)

        expect(customer.status_chat).to eq('open_chat')

        chat_history = ChatHistory.last
        expect(chat_history.chat_status).to eq('chat_open')
        expect(chat_history.action).to eq('mark_as')
        expect(chat_history.retailer_user_id).to eq(retailer_user.id)
      end
    end

    context 'when the chat is not on new_chat status' do
      let(:customer) { create(:customer, retailer: retailer, status_chat: 'in_process') }

      it 'does not update the chat to open_chat status' do
        expect {
          customer.open_chat!(retailer_user)
        }.to change(ChatHistory, :count).by(0)

        expect(customer.status_chat).to eq('in_process')
      end
    end
  end

  describe '#set_in_process' do
    let(:retailer) { create(:retailer) }
    let(:retailer_user) { create(:retailer_user, :admin, retailer: retailer) }

    context 'when the chat is on open_chat status' do
      let(:customer) { create(:customer, retailer: retailer, status_chat: 'open_chat') }

      it 'updates the chat to in_process status' do
        expect {
          customer.set_in_process!(retailer_user)
        }.to change(ChatHistory, :count).by(1)

        expect(customer.status_chat).to eq('in_process')

        chat_history = ChatHistory.last
        expect(chat_history.chat_status).to eq('chat_in_process')
        expect(chat_history.action).to eq('mark_as')
        expect(chat_history.retailer_user_id).to eq(retailer_user.id)
      end
    end

    context 'when the chat is not on open_chat status' do
      context 'when the update comes from an answer message' do
        let(:customer) { create(:customer, retailer: retailer, status_chat: 'new_chat') }

        it 'updates the chat to in_process status' do
          expect {
            customer.set_in_process!(retailer_user, true)
          }.to change(ChatHistory, :count).by(1)

          expect(customer.status_chat).to eq('in_process')

          chat_history = ChatHistory.last
          expect(chat_history.chat_status).to eq('chat_in_process')
          expect(chat_history.action).to eq('mark_as')
          expect(chat_history.retailer_user_id).to eq(retailer_user.id)
        end
      end

      context 'when the update does not come from an answer message' do
        let(:customer) { create(:customer, retailer: retailer, status_chat: 'new_chat') }

        it 'does not update the chat to in_process status' do
          expect {
            customer.set_in_process!(retailer_user)
          }.to change(ChatHistory, :count).by(0)

          expect(customer.status_chat).to eq('new_chat')
        end
      end
    end
  end

  describe '#change_status_chat' do
    let(:retailer) { create(:retailer) }
    let(:retailer_user) { create(:retailer_user, :admin, retailer: retailer) }

    context 'when changing to resolved status' do
      context 'when the chat does not have the status yet' do
        let(:customer) { create(:customer, retailer: retailer, status_chat: 'in_process') }

        it 'sets the chat as resolved' do
          expect {
            customer.change_status_chat(retailer_user, { status_chat: 'resolved' })
          }.to change(ChatHistory, :count).by(1)

          expect(customer.status_chat).to eq('resolved')

          chat_history = ChatHistory.last
          expect(chat_history.chat_status).to eq('chat_resolved')
          expect(chat_history.action).to eq('change_to')
          expect(chat_history.retailer_user_id).to eq(retailer_user.id)
        end
      end

      context 'when the chat has the status already' do
        let(:customer) { create(:customer, retailer: retailer, status_chat: 'resolved') }

        it 'does not set the chat as resolved' do
          expect {
            customer.change_status_chat(retailer_user, { status_chat: 'resolved' })
          }.to change(ChatHistory, :count).by(0)
        end
      end
    end

    context 'when changing to in_process status' do
      context 'when the chat does not have the status yet' do
        let(:customer) { create(:customer, retailer: retailer, status_chat: 'resolved') }

        it 'sets the chat as in_process' do
          expect {
            customer.change_status_chat(retailer_user, { status_chat: 'in_process' })
          }.to change(ChatHistory, :count).by(1)

          expect(customer.status_chat).to eq('in_process')

          chat_history = ChatHistory.last
          expect(chat_history.chat_status).to eq('chat_in_process')
          expect(chat_history.action).to eq('change_to')
          expect(chat_history.retailer_user_id).to eq(retailer_user.id)
        end
      end

      context 'when the chat has the status already' do
        let(:customer) { create(:customer, retailer: retailer, status_chat: 'in_process') }

        it 'does not set the chat as in_process' do
          expect {
            customer.change_status_chat(retailer_user, { status_chat: 'in_process' })
          }.to change(ChatHistory, :count).by(0)
        end
      end
    end

    context 'when changing to open_chat status' do
      context 'when the chat is on new_chat status' do
        let(:customer) { create(:customer, retailer: retailer, status_chat: 'new_chat') }

        it 'sets the chat as open_chat' do
          expect {
            customer.change_status_chat(retailer_user, { status_chat: 'open_chat' })
          }.to change(ChatHistory, :count).by(1)

          expect(customer.status_chat).to eq('open_chat')

          chat_history = ChatHistory.last
          expect(chat_history.chat_status).to eq('chat_open')
          expect(chat_history.action).to eq('change_to')
          expect(chat_history.retailer_user_id).to eq(retailer_user.id)
        end
      end

      context 'when the chat is not on new_chat status' do
        let(:customer) { create(:customer, retailer: retailer, status_chat: 'in_process') }

        it 'does not set the chat as open_chat' do
          expect {
            customer.change_status_chat(retailer_user, { status_chat: 'in_process' })
          }.to change(ChatHistory, :count).by(0)
        end
      end
    end
  end

  describe '#reactivate_chat' do
    let(:retailer) { create(:retailer) }

    context 'when the chat is on resolved status' do
      let(:customer) { create(:customer, retailer: retailer, status_chat: 'resolved') }

      it 'updates the chat to new_chat status' do
        expect {
          customer.reactivate_chat!
        }.to change(ChatHistory, :count).by(1)

        expect(customer.status_chat).to eq('new_chat')

        chat_history = ChatHistory.last
        expect(chat_history.chat_status).to eq('chat_new')
        expect(chat_history.action).to eq('customer_mark_as')
        expect(chat_history.retailer_user_id).to be_nil
      end
    end

    context 'when the chat is not on resolved status' do
      let(:customer) { create(:customer, retailer: retailer, status_chat: 'open_chat') }

      it 'does not update the chat to resolved status' do
        expect {
          customer.reactivate_chat!
        }.to change(ChatHistory, :count).by(0)

        expect(customer.status_chat).to eq('open_chat')
      end
    end
  end
end
