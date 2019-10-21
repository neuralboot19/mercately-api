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

  describe '#send_welcome_email' do
    it 'sends a welcome email after creating a retailer user' do
      expect { retailer_user.save }.to change { ActionMailer::Base.deliveries.size }.by(1)
    end
  end
end
