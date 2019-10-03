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

  describe '#send_welcome_email' do
    it 'after save sends a welcome email' do
      expect { retailer_user.save }.to change { ActionMailer::Base.deliveries.size }.by(1)
    end
  end
end
