require 'rails_helper'

RSpec.describe ContactGroup, type: :model do
  subject(:contact_group) { build(:contact_group) }

  let(:customers) { create_list(:customer, 2, retailer: contact_group.retailer) }
  let(:service_response) { { code: '202' } }

  before do
    allow_any_instance_of(Whatsapp::Gupshup::V1::Outbound::Users).to receive(:opt_in).and_return(service_response)
  end

  describe 'associations' do
    it { is_expected.to belong_to(:retailer) }
    it { is_expected.to have_many(:customers).through(:contact_group_customers) }
    it { is_expected.to have_many(:campaigns) }
  end

  describe '#check_customers' do
    it 'checks the record has customers' do
      expect(contact_group.save).to be false
      contact_group.customers << customers
      expect(contact_group.save).to be true
    end

    context 'when imported' do
      it 'skips validation' do
        contact_group.imported = true
        expect(contact_group.customers.count).to eq 0
        expect(contact_group.save).to be true
      end
    end
  end
end
