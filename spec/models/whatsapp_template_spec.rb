require 'rails_helper'

RSpec.describe WhatsappTemplate, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:retailer) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(%i[inactive active]) }
  end

  describe '#clean_template' do
    context 'when the templates has formatting asterisks' do
      let(:template) { create(:whatsapp_template, :with_formatting_asterisks) }

      it 'returns the template replacing \* by *' do
        expect(template.clean_template).to eq('This is a *test* with formatting asterisks')
      end
    end

    context 'when the templates does not have formatting asterisks' do
      let(:template) { create(:whatsapp_template, :without_formatting_asterisks) }

      it 'returns the template as is' do
        expect(template.clean_template).to eq('This is a * without * formatting asterisks')
      end
    end
  end
end
