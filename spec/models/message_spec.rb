require 'rails_helper'

RSpec.describe Message, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:order) }
    it { is_expected.to belong_to(:customer) }
    it { is_expected.to belong_to(:sender).with_foreign_key(:sender_id).class_name('RetailerUser').optional }
  end

  describe 'delegates' do
    it { is_expected.to delegate_method(:retailer_id).to(:customer) }
    it { is_expected.to delegate_method(:retailer).to(:customer) }
  end

  describe '#generate_web_id' do
    let(:message) { build(:message) }

    it 'generates the web_id field to messages' do
      expect(message.web_id).to be_nil
      message.save
      expect(message.web_id).not_to be_nil
    end
  end

  describe '#to_param' do
    let(:message) { create(:message) }

    it 'returns the message web_id' do
      message.save
      expect(message.to_param).to eq(message.web_id)
    end
  end
end
