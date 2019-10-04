require 'rails_helper'

RSpec.describe MeliRetailer, type: :model do
  subject(:meli_retailer) { build(:meli_retailer) }

  describe 'associations' do
    it { is_expected.to belong_to(:retailer) }
  end

  describe '.check_unique_retailer_id' do
    context 'when it does not exist yet' do
      it 'let the meli_retailer creation' do
        expect(MeliRetailer.check_unique_retailer_id(meli_retailer.meli_user_id)).to be false
      end
    end

    context 'when it already exists' do
      it 'rejects the meli_retailer creation' do
        meli_retailer.save
        expect(MeliRetailer.check_unique_retailer_id(meli_retailer.meli_user_id)).to be true
      end
    end
  end

  describe '#update_information' do
    context 'when is a new record' do
      it 'calls the ML updating service' do
        meli_retailer.meli_info_updated_at = nil
        expect(meli_retailer.send(:update_information)).to be_a MeliRetailer
      end
    end

    context 'when it has not been updated in more than 7 days' do
      it 'calls the ML updating service' do
        meli_retailer.meli_info_updated_at = Time.now - 8.days
        expect(meli_retailer.send(:update_information)).to be_a MeliRetailer
      end
    end

    context 'when it has been updated in less than 7 days' do
      it 'does not call the ML updating service' do
        meli_retailer.meli_info_updated_at = Time.now - 5.days
        expect(meli_retailer.send(:update_information)).to be_nil
      end
    end
  end
end
