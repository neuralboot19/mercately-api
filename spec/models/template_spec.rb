require 'rails_helper'

RSpec.describe Template, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:retailer) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:answer) }
  end

  describe 'persistence' do
    let(:template) { create(:template) }

    it 'has a non-nil title' do
      expect(template.title).not_to eq(nil)
    end

    it 'has a non-empty title' do
      expect(template.title).not_to eq('')
    end

    it 'has a non-nil answer' do
      expect(template.answer).not_to eq(nil)
    end

    it 'has a non-empty answer' do
      expect(template.answer).not_to eq('')
    end

    it 'has a Retailer' do
      expect(template.retailer).not_to eq(nil)
    end
  end
end
