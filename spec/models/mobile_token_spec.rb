require 'rails_helper'

RSpec.describe MobileToken, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:retailer_user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:retailer_user) }
  end

  describe '#set_device' do
    it 'will have a device set' do
      mobile_token = create(:mobile_token)

      expect(mobile_token.device).not_to be(nil)
    end
  end

  describe '#generate!' do
    it 'will generate a token and store update the record' do
      mobile_token = create(:mobile_token)
      old_token = mobile_token.token

      new_token = mobile_token.generate!
      expect(mobile_token.token).not_to eq(old_token)
      expect(mobile_token.token).to eq(new_token)
    end
  end
end
