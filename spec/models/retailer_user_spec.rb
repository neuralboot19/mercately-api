require 'rails_helper'

RSpec.describe RetailerUser, type: :model do
  subject(:retailer_user) { build(:retailer_user, :with_retailer) }

  describe 'associations' do
    it { is_expected.to have_many(:agent_customers) }
    it { is_expected.to have_many(:mobile_tokens) }
    it { is_expected.to belong_to(:retailer) }
    it { is_expected.to accept_nested_attributes_for(:retailer) }
  end
  describe 'validations' do
    it { is_expected.to validate_presence_of(:agree_terms) }
  end

  describe '#onboarding_status_format' do
    it 'validates the onboarding_status format' do
      # A valid hash is set as default in migration
      retailer_user.save
      expect(retailer_user.persisted?).to eq true
    end

    context 'with invalid options' do
      it 'returns a validation error' do
        retailer_user.onboarding_status = { step: 5, skipped: 'invalid value', invalid_key: true }
        expect(retailer_user.save).to eq false
      end
    end
  end

  describe '#active_for_authentication?' do
    context 'when retailer user is removed from team' do
      it 'returns false' do
        retailer_user.removed_from_team = true
        retailer_user.save
        expect(retailer_user.active_for_authentication?).to be false
      end
    end

    context 'when retailer user is not removed from team' do
      it 'returns true' do
        retailer_user.save
        expect(retailer_user.active_for_authentication?).to be true
      end
    end
  end

  describe '#inactive_message' do
    context 'when retailer user is removed from team' do
      it 'returns inactive message' do
        retailer_user.removed_from_team = true
        retailer_user.save
        expect(retailer_user.inactive_message).to eq('Tu cuenta no se encuentra activa')
      end
    end

    context 'when retailer user is not removed from team' do
      it 'returns true' do
        retailer_user.save
        expect(retailer_user.active_for_authentication?).to be true
      end
    end
  end

  describe '#full_name' do
    it 'returns a full name' do
      retailer_user  = described_class.new(first_name: 'John', last_name: 'Wick')

      expect(retailer_user.full_name).to eq('John Wick')
    end
  end

  describe '#admin?' do
    subject(:retailer_user) { create(:retailer_user, :with_retailer, :admin) }

    let(:retailer_user_agent) { create(:retailer_user, :with_retailer, :agent) }

    context 'when the retailer user is an admin' do
      it 'returns true' do
        expect(retailer_user.admin?).to be true
      end
    end

    context 'when the retailer user is not an admin' do
      it 'returns false' do
        expect(retailer_user_agent.admin?).to be false
      end
    end
  end

  describe '#agent?' do
    subject(:retailer_user) { create(:retailer_user, :with_retailer, :admin) }

    let(:retailer_user_agent) { create(:retailer_user, :with_retailer, :agent) }

    context 'when the retailer user is an agent' do
      it 'returns true' do
        expect(retailer_user_agent.agent?).to be true
      end
    end

    context 'when the retailer user is not an agent' do
      it 'returns false' do
        expect(retailer_user.agent?).to be false
      end
    end
  end

  describe '#customers' do
    let(:retailer) { create(:retailer) }
    let(:customer_one) { create(:customer, retailer: retailer) }
    let(:customer_two) { create(:customer, retailer: retailer) }
    let!(:customer_three) { create(:customer, retailer: retailer) }
    let(:retailer_user_one) { create(:retailer_user, :with_retailer, retailer: retailer) }
    let(:retailer_user_two) { create(:retailer_user, :with_retailer, retailer: retailer) }

    let!(:agent_customer_one) do
      create(:agent_customer, retailer_user: retailer_user_one, customer: customer_one)
    end

    let!(:agent_customer_two) do
      create(:agent_customer, retailer_user: retailer_user_two, customer: customer_two)
    end

    it 'returns the customers belonging to the retailer user or those not assigned' do
      expect(retailer_user_one.customers.count).to eq(2)
    end
  end
end
