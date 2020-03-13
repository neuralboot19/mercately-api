require 'rails_helper'

RSpec.describe RetailerUser, type: :model do
  subject(:retailer_user) { build(:retailer_user) }

  describe 'associations' do
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
end
