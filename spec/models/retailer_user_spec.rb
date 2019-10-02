require 'rails_helper'

RSpec.describe RetailerUser, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:retailer) }
    it { is_expected.to accept_nested_attributes_for(:retailer) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:agree_terms) }
  end

  describe 'protected/private methods' do
    let(:retailer_user) { create(:retailer_user) }

    it 'returns true for agree terms converter' do
      expect(retailer_user.send(:agree_terms_to_bool)).to be_truthy
    end

    it 'sends a welcome email' do
      expect(retailer_user.send(:send_welcome_email)).to be_a Mail::Message
    end
  end
end
