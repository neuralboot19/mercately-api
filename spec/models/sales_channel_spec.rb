require 'rails_helper'

RSpec.describe SalesChannel, type: :model do
  subject(:sales_channel) { create(:sales_channel) }

  describe 'enums' do
    it { is_expected.to define_enum_for(:channel_type).with_values(%i[other mercadolibre whatsapp messenger]) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:retailer) }
    it { is_expected.to have_many(:orders) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title).with_message('Título no puede estar vacío') }
  end

  describe '#to_param' do
    it 'returns the sales channel web id' do
      expect(sales_channel.to_param).to eq(sales_channel.web_id)
    end
  end

  describe '#check_destroy_requirements' do
    let(:retailer) { create(:retailer) }

    context 'when the sales channel type is not other' do
      let(:sales_channel) { create(:sales_channel, :whatsapp, retailer: retailer) }

      it 'inserts the error to the model base' do
        expect { sales_channel.send(:check_destroy_requirements) }.to throw_symbol(:abort)
        expect(sales_channel.reload.errors['base'][0]).to eq('Canal no se puede eliminar, pertenece a una integración')
      end
    end

    context 'when the sales channel type is other' do
      let(:sales_channel) { create(:sales_channel, retailer: retailer) }

      it 'does not insert the error to the model base' do
        sales_channel.send(:check_destroy_requirements)
        expect(sales_channel.reload.errors['base']).to be_empty
      end
    end

    context 'when the sales channel has at least one order associated' do
      let(:sales_channel) { create(:sales_channel, retailer: retailer) }
      let!(:order) { create(:order, sales_channel: sales_channel) }

      it 'inserts the error to the model base' do
        expect { sales_channel.send(:check_destroy_requirements) }.to throw_symbol(:abort)
        expect(sales_channel.reload.errors['base'][0]).to eq('Canal no se puede eliminar, posee ventas asociadas')
      end
    end

    context 'when the sales channel does not have orders associated' do
      let!(:sales_channel) { create(:sales_channel, retailer: retailer) }

      it 'does not insert the error to the model base' do
        sales_channel.send(:check_destroy_requirements)
        expect(sales_channel.reload.errors['base']).to be_empty
      end
    end
  end
end
