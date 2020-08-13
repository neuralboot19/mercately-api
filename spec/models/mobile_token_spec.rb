require 'rails_helper'

RSpec.describe MobileToken, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:retailer_user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:retailer_user) }
  end

  describe 'scopes' do
    let!(:expired) { create(:mobile_token, :expired) }
    let!(:active) { create(:mobile_token) }

    it 'will return expired tokens' do
      expect(described_class.expired.count).to eq(1)
    end

    it 'will return active tokens' do
      expect(described_class.active.count).to eq(1)
    end
  end

  describe '#set_device' do
    it 'will have a device set' do
      mobile_token = create(:mobile_token)

      expect(mobile_token.device).to_not be(nil)
    end
  end

  describe '#clean_expired' do
    it 'will destroy all expired' do
      # stubbing the Rails.env to production
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))

      create(:mobile_token)
      create(:mobile_token, :expired)

      expect(MobileToken.count).to eq(1)
    end
  end

  describe '#generate!' do
    it 'will generate a token and store update the record' do
      mobile_token = create(:mobile_token)
      old_token = mobile_token.token

      new_token = mobile_token.generate!
      expect(mobile_token.token).to_not eq(old_token)
      expect(mobile_token.token).to eq(new_token)
    end
  end
end
