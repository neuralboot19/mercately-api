require 'rails_helper'

RSpec.describe GupshupWhatsappMessage, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:retailer) }
    it { is_expected.to belong_to(:customer) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:retailer) }
    it { is_expected.to validate_presence_of(:customer) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:direction) }
    it { is_expected.to validate_presence_of(:source) }
    it { is_expected.to validate_presence_of(:destination) }
    it { is_expected.to validate_presence_of(:channel) }
  end

  describe 'scopes' do
    let(:inbound) { create(:gupshup_whatsapp_message, :inbound, created_at: Time.now - 2.hours) }

    let(:inbound) { create(:gupshup_whatsapp_message, :inbound, created_at: Time.now - 2.hours) }
    let(:outbound) { create(:gupshup_whatsapp_message, :outbound, created_at: Time.now - 3.minutes) }

    let(:notification_message) { create(:gupshup_whatsapp_message, :notification, created_at: Time.now - 3.minutes) }
    let(:conversation_message) { create(:gupshup_whatsapp_message, :conversation, created_at: Time.now - 3.minutes) }

    it 'will return inbound messages' do
      inbound
      expect(described_class.inbound_messages.count).to eq(1)
    end

    it 'will return outbound messages' do
      outbound
      expect(described_class.outbound_messages.count).to eq(1)
    end

    it 'will return notification messages' do
      notification_message
      expect(described_class.notification_messages.count).to eq(1)
    end

    it 'will return conversation messages' do
      conversation_message
      expect(described_class.conversation_messages.count).to eq(1)
    end

    it 'will return messages by range' do
      inbound
      outbound
      notification_message
      conversation_message
      expect(described_class.range_between(Time.now - 1.hour, Time.now).count).to eq(3)
    end
  end

  context 'set message type' do
    let(:message) { build(:gupshup_whatsapp_message) }

    it 'is conversation after create if isHSM = false' do
      message.message_payload = { 'isHSM': 'false' }
      message.save!
      expect(message.message_type).to eq('conversation')
    end

    it 'is notification after create if isHSM = true' do
      message.message_payload = { 'isHSM': 'true' }
      message.save!
      expect(message.message_type).to eq('notification')
    end
  end

  context '#type' do
    it 'returns the message outbound payload type' do
      message = build(:gupshup_whatsapp_message)
      message.message_payload = { 'isHSM': 'false', 'type': 'text' }
      message.save!

      expect(message.type).to eq('text')
    end

    it 'returns the message inbound payload type' do
      message = build(:gupshup_whatsapp_message)
      message.message_payload = { 'payload': { 'type': 'document' } }
      message.save!

      expect(message.type).to eq('document')
    end
  end
end
