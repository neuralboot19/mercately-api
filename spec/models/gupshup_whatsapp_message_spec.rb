require 'rails_helper'

RSpec.describe GupshupWhatsappMessage, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:retailer) }
    it { is_expected.to belong_to(:customer) }
    it { is_expected.to belong_to(:retailer_user).required(false) }
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

  describe '#send_welcome_message' do
    let(:set_gupshup_messages_service) { instance_double(Whatsapp::Gupshup::V1::Outbound::Msg) }

    before do
      allow(set_gupshup_messages_service).to receive(:send_message)
        .and_return('Sent')
      allow(Whatsapp::Gupshup::V1::Outbound::Msg).to receive(:new)
        .and_return(set_gupshup_messages_service)
    end

    context 'when the retailer does not have an active welcome message configured' do
      let(:retailer) { create(:retailer, :gupshup_integrated) }
      let(:customer) { create(:customer, retailer: retailer) }

      let(:message) do
        create(:gupshup_whatsapp_message, :inbound, customer: customer)
      end

      it 'returns nil' do
        expect(message.send(:send_welcome_message)).to be nil
      end
    end

    context 'when the customer does not text for the first time' do
      let!(:automatic_answer) { create(:automatic_answer, :welcome, :whatsapp, retailer: retailer) }
      let(:retailer) { create(:retailer, :gupshup_integrated) }
      let(:customer) { create(:customer, retailer: retailer) }

      let!(:first_message) do
        create(:gupshup_whatsapp_message, :inbound, customer: customer)
      end

      let(:message) do
        create(:gupshup_whatsapp_message, :inbound, customer: customer)
      end

      it 'returns nil' do
        expect(message.send(:send_welcome_message)).to be nil
      end
    end

    context 'when the message is not inbound' do
      let!(:automatic_answer) { create(:automatic_answer, :welcome, :whatsapp, retailer: retailer) }
      let(:retailer) { create(:retailer, :gupshup_integrated) }
      let(:customer) { create(:customer, retailer: retailer) }

      let(:message) do
        create(:gupshup_whatsapp_message, :outbound, customer: customer)
      end

      it 'returns nil' do
        expect(message.send(:send_welcome_message)).to be nil
      end
    end

    context 'when all conditions are present' do
      let!(:automatic_answer) { create(:automatic_answer, :welcome, :whatsapp, retailer: retailer) }
      let(:retailer) { create(:retailer, :gupshup_integrated) }
      let(:customer) { create(:customer, retailer: retailer) }

      let(:message) do
        create(:gupshup_whatsapp_message, :inbound, customer: customer, retailer: customer.retailer)
      end

      it 'sends the message' do
        expect(message.send(:send_welcome_message)).to eq('Sent')
      end
    end
  end

  describe '#send_inactive_message' do
    let(:set_gupshup_messages_service) { instance_double(Whatsapp::Gupshup::V1::Outbound::Msg) }

    before do
      allow(set_gupshup_messages_service).to receive(:send_message)
        .and_return('Sent')
      allow(Whatsapp::Gupshup::V1::Outbound::Msg).to receive(:new)
        .and_return(set_gupshup_messages_service)
    end

    context 'when the retailer does not have an inactive message configured' do
      let(:retailer) { create(:retailer, :gupshup_integrated) }
      let(:customer) { create(:customer, retailer: retailer) }

      let!(:first_message) do
        create(:gupshup_whatsapp_message, :inbound, customer: customer)
      end

      let(:message) do
        create(:gupshup_whatsapp_message, :inbound, customer: customer)
      end

      it 'returns nil' do
        expect(message.send(:send_inactive_message)).to be nil
      end
    end

    context 'when the customer does not have a prior message sent' do
      let!(:automatic_answer) { create(:automatic_answer, :inactive, :whatsapp, retailer: retailer) }
      let(:retailer) { create(:retailer, :gupshup_integrated) }
      let(:customer) { create(:customer, retailer: retailer) }

      let(:message) do
        create(:gupshup_whatsapp_message, :inbound, customer: customer)
      end

      it 'returns nil' do
        expect(message.send(:send_inactive_message)).to be nil
      end
    end

    context 'when the message is not inbound' do
      let!(:automatic_answer) { create(:automatic_answer, :inactive, :whatsapp, retailer: retailer) }
      let(:retailer) { create(:retailer, :gupshup_integrated) }
      let(:customer) { create(:customer, retailer: retailer) }

      let!(:first_message) do
        create(:gupshup_whatsapp_message, :inbound, customer: customer)
      end

      let(:message) do
        create(:gupshup_whatsapp_message, :outbound, customer: customer)
      end

      it 'returns nil' do
        expect(message.send(:send_inactive_message)).to be nil
      end
    end

    context 'when the created time of the prior message is not passed yet' do
      let!(:automatic_answer) { create(:automatic_answer, :inactive, :whatsapp, retailer: retailer) }
      let(:retailer) { create(:retailer, :gupshup_integrated) }
      let(:customer) { create(:customer, retailer: retailer) }

      let!(:first_message) do
        create(:gupshup_whatsapp_message, :inbound, customer: customer, created_at:
          Time.now - 11.hours)
      end

      let(:message) do
        create(:gupshup_whatsapp_message, :inbound, customer: customer)
      end

      it 'returns nil' do
        expect(message.send(:send_inactive_message)).to be nil
      end
    end

    context 'when all conditions are present' do
      let!(:automatic_answer) { create(:automatic_answer, :inactive, :whatsapp, retailer: retailer) }
      let(:retailer) { create(:retailer, :gupshup_integrated) }
      let(:customer) { create(:customer, retailer: retailer) }

      let!(:first_message) do
        create(:gupshup_whatsapp_message, :inbound, retailer: retailer, customer: customer, created_at:
          Time.now - 13.hours)
      end

      let(:message) do
        create(:gupshup_whatsapp_message, :inbound, customer: customer, retailer: customer.retailer)
      end

      it 'sends the message' do
        expect(message.send(:send_inactive_message)).to eq('Sent')
      end
    end
  end

  describe '#apply_cost' do
    let(:retailer) { create(:retailer, :gupshup_integrated) }

    context 'when the message status is not error' do
      let(:message) { build(:gupshup_whatsapp_message, retailer: retailer) }

      context 'when the message cost is zero' do
        it 'assigns the retailer conversation/notification cost to the message' do
          expect(message.cost).to be nil
          message.save
          expect(message.reload.cost).to eq(retailer.send("ws_#{message.message_type}_cost"))
        end
      end

      context 'when the message cost is not zero' do
        it 'does not change the message cost' do
          expect(message.cost).to be nil
          message.cost = 0.05
          message.save
          expect(message.reload.cost).to eq(0.05)
        end
      end
    end

    context 'when the message status is error' do
      let(:message) do
        build(:gupshup_whatsapp_message, retailer: retailer, status: 'error', cost: 0.05)
      end

      context 'when the message cost is not zero' do
        it 'sets the message cost to zero' do
          expect(message.cost).to eq(0.05)
          message.save
          expect(message.reload.cost).to eq(0)
        end
      end

      context 'when the message cost is zero' do
        it 'does not change the message cost' do
          message.cost = 0
          expect(message.cost).to eq(0)
          message.save
          expect(message.reload.cost).to eq(0)
        end
      end
    end
  end
end
