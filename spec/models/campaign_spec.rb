require 'rails_helper'

RSpec.describe Campaign, type: :model do
  subject(:campaign) { build(:campaign, :with_sent_messages) }

  let(:service_response) { { code: '202' } }

  before do
    allow_any_instance_of(Whatsapp::Gupshup::V1::Outbound::Users).to receive(:opt_in).and_return(service_response)
    campaign.save!
  end

  describe 'associations' do
    it { is_expected.to belong_to(:retailer) }
    it { is_expected.to belong_to(:contact_group) }
    it { is_expected.to belong_to(:whatsapp_template) }
    it { is_expected.to have_many(:gupshup_whatsapp_messages) }
    it { is_expected.to have_many(:karix_whatsapp_messages) }
  end

  describe '#cost' do
    it 'returns 0 if campaign not sent' do
      expect(campaign.cost).to eq 0
    end

    context 'when campaign sent' do
      it 'calculates the real campaign\'s cost' do
        campaign.sent!
        expect(campaign.cost).to eq 0.0565
      end
    end
  end

  describe '#estimated_cost' do
    it 'calculates the campaign estimated cost' do
      expect(campaign.estimated_cost).to eq 0.226
    end
  end

  describe '#customer_details_template(customer)' do
    it 'replaces {{\w}} with customer variables' do
      customer = campaign.contact_group.customers.first
      expect(campaign.customer_details_template(customer)).to eq "Hi #{customer.first_name}. Welcome to our WhatsApp. We will be here for any question."
    end
  end
end
