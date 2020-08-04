require 'rails_helper'

RSpec.describe Template, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:retailer) }
    it { is_expected.to have_one(:image_attachment) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
  end

  describe '#generate_web_id' do
    let(:template) { build(:template) }

    it 'generates the web_id field to templates' do
      expect(template.web_id).to be_nil
      template.save
      expect(template.web_id).not_to be_nil
    end
  end

  describe '#to_param' do
    let(:template) { create(:template) }

    it 'returns the template web_id' do
      template.save
      expect(template.to_param).to eq(template.web_id)
    end
  end
end
