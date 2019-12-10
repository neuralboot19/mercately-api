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
    let(:retailer) { create(:retailer) }
    let(:customer) { create(:customer, retailer: retailer) }
    let(:order) { create(:order, customer: customer) }
    let(:message) { build(:message, order: order, customer: customer) }

    it 'generates the web_id field to messages' do
      expect(message.web_id).to be_nil
      message.save
      expect(message.web_id).to eq(retailer.web_id + message.id.to_s)
    end
  end
end
