require 'rails_helper'

RSpec.describe Template, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:retailer) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:answer) }
  end

  describe '#generate_web_id' do
    let(:retailer) { create(:retailer) }
    let(:template) { build(:template, retailer: retailer) }

    it 'generates the web_id field to templates' do
      expect(template.web_id).to be_nil
      template.save
      expect(template.web_id).to eq(retailer.web_id + template.id.to_s)
    end
  end
end
