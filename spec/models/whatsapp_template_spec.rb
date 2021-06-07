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

  describe '#check_params_match' do
    let(:template) { create(:whatsapp_template, :with_text) }

    it 'checks params required vs params sent' do
      expect(template.check_params_match(template_params: ['Daniel'])).to eq [true, 1, 1]
    end

    context 'when no vars required' do
      let(:template) { create(:whatsapp_template, :with_formatting_asterisks) }

      it 'returns true' do
        expect(template.check_params_match(template_params: [])).to eq [true, 0, 0]
      end
    end

    context 'when not all params sent' do
      it 'returns false' do
        expect(template.check_params_match(template_params: [])).to eq [false, 1, 0]
      end
    end
  end

  describe '#template_text' do
    let(:template) { create(:whatsapp_template, :with_text) }

    it 'replaces * with sent variables' do
      expect(template.template_text(template_params: ['Daniel'])).to eq 'Hi Daniel. Welcome to our WhatsApp. We will be here for any question.'
    end

    context 'when have no variables to replace' do
      let(:template) { create(:whatsapp_template, :with_formatting_asterisks) }

      it 'prints the template' do
        expect(template.template_text(template_params: ['Daniel'])).to eq('This is a \*test\* with formatting asterisks')
      end
    end

    context 'when not sent all variables' do
      it 'replaces removes not yet replaced *' do
        expect(template.template_text(template_params: [])).to eq 'Hi . Welcome to our WhatsApp. We will be here for any question.'
      end
    end
  end
end
