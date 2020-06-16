require 'rails_helper'

RSpec.describe Tag, type: :model do
  subject(:tag) { create(:tag) }

  describe 'associations' do
    it { is_expected.to belong_to(:retailer) }
    it { is_expected.to have_many(:customer_tags).dependent(:destroy) }
    it { is_expected.to have_many(:customers).through(:customer_tags) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:tag) }
  end

  describe '#to_param' do
    it 'returns the tag web id' do
      expect(tag.to_param).to eq(tag.web_id)
    end
  end
end
