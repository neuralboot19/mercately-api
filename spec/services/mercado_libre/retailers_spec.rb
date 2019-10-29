require 'rails_helper'
require 'vcr'

RSpec.describe MercadoLibre::Retailer, vcr: true do
  subject(:retailers_service) { described_class.new(retailer) }

  let(:retailer) { meli_retailer.retailer }
  let(:meli_retailer) { create(:meli_retailer) }

  describe '#update_retailer_info' do
    it 'updates meli_user_id fields' do
      VCR.use_cassette('retailers/retailer') do
        retailers_service.update_retailer_info
        expect(meli_retailer.nickname).to eq 'TETE5900055'
      end
    end

    context 'when retailer is not active in ML' do
      it 'sets the meli_user_active to false' do
        VCR.use_cassette('retailers/retailer_not_active') do
          retailers_service.update_retailer_info
          expect(meli_retailer.meli_user_active).to eq false
        end
      end
    end
  end
end
