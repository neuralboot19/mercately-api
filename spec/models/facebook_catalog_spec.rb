require 'rails_helper'

RSpec.describe FacebookCatalog, type: :model do
  subject(:facebook_catalog) { create(:facebook_catalog) }

  describe 'associations' do
    it { is_expected.to belong_to(:retailer) }
  end

  describe 'validations' do
    it { is_expected.to validate_uniqueness_of(:uid).with_message('Catálogo ya está asociado' \
      ' con una cuenta de Mercately').allow_blank }
    it { is_expected.to validate_uniqueness_of(:business_id).with_message('Administrador de' \
      ' negocio ya está asociado con una cuenta de Mercately').allow_blank }
  end

  describe '#connected?' do
    context 'when the facebook catalog uid data is set' do
      it 'returns true' do
        expect(facebook_catalog.connected?).to be true
      end
    end

    context 'when the facebook catalog uid data is not set' do
      it 'returns false' do
        facebook_catalog.update(uid: nil)
        expect(facebook_catalog.connected?).to be false
      end
    end
  end
end
