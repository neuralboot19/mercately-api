require 'rails_helper'

RSpec.describe Customer, type: :model do
  subject(:customer) { create(:customer) }

  describe 'associations' do
    it { is_expected.to belong_to(:retailer) }
    it { is_expected.to belong_to(:meli_customer).optional }
    it { is_expected.to have_many(:orders).dependent(:destroy) }
    it { is_expected.to have_many(:questions).dependent(:destroy) }
    it { is_expected.to have_many(:messages).dependent(:destroy) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:id_type).with_values(%i[cedula pasaporte ruc]) }
  end

  describe '#full_name' do
    it { expect(customer.full_name).to eq "#{customer.first_name} #{customer.last_name}" }
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
end
