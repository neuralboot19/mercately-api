require 'rails_helper'

RSpec.describe MeliRetailer, type: :model do
  subject(:meli_retailer) { build(:meli_retailer) }

  describe 'associations' do
    it { is_expected.to belong_to(:retailer) }
  end

  describe '.check_unique_meli_user_id' do
    context 'when meli_user_id does not exist yet' do
      it 'let the meli_retailer creation' do
        expect(described_class.check_unique_meli_user_id(meli_retailer.meli_user_id)).to be false
      end
    end

    context 'when meli_user_id already exists' do
      it 'rejects the meli_retailer creation' do
        meli_retailer.save
        expect(described_class.check_unique_meli_user_id(meli_retailer.meli_user_id)).to be true
      end
    end
  end

  describe '#update_information' do
    let(:ml_retailer) { instance_double(MercadoLibre::Retailer) }

    before do
      allow(ml_retailer).to receive(:update_retailer_info)
        .and_return('Successfully updated')
      allow(MercadoLibre::Retailer).to receive(:new).with(meli_retailer.retailer)
        .and_return(ml_retailer)
    end

    context 'when it has not been updated in more than 7 days' do
      it 'calls the ML updating service' do
        meli_retailer.meli_info_updated_at = Time.now - 8.days
        expect(meli_retailer.send(:update_information)).to eq 'Successfully updated'
      end
    end

    context 'when it has been updated in less than 7 days' do
      it 'does not call the ML updating service' do
        meli_retailer.meli_info_updated_at = Time.now - 5.days
        expect(meli_retailer.send(:update_information)).to be_nil
      end
    end

    context 'when the user is deactive in ML' do
      it 'does not call the ML updating service' do
        meli_retailer.meli_info_updated_at = Time.now - 8.days
        meli_retailer.meli_user_active = false
        expect(meli_retailer.send(:update_information)).to be_nil
      end
    end
  end
end
