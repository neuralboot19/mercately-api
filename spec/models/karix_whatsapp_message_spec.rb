require 'rails_helper'

RSpec.describe KarixWhatsappMessage, type: :model do
  let(:karix_response) do
    {
      'meta': {
        'request_uuid': '01678427-c79f-48f7-bf03-b04659611c2e',
        'available_credits': '1.51226',
        'credits_charged': '0.004'
      },
      'objects':
      [
        {
          'account_uid': '3a9f05a1-4e59-4504-9ca9-be9ec1934f2b',
          'channel': 'whatsapp',
          'channel_details': {
            'whatsapp': {
              'platform_fee': '0.004',
              'type': 'conversation',
              'whatsapp_fee': '0'
            }
          },
          'content': {
            'text': 'New Whatsapp message'
          },
          'content_type': 'text',
          'country': 'EC',
          'created_time': '2020-03-18T15:01:14.624018Z',
          'delivered_time': nil,
          'destination': '+593998999999',
          'direction': 'outbound',
          'error': nil,
          'redact': false,
          'refund': nil,
          'sent_time': nil,
          'source': '+13253077759',
          'status': 'queued',
          'total_cost': '0.004',
          'uid': '87f3c742-95e3-4bb3-a671-cce2705e1a21',
          'updated_time': nil
        }
      ]
    }.with_indifferent_access
  end

  describe 'associations' do
    it { is_expected.to belong_to(:retailer) }
    it { is_expected.to belong_to(:customer) }
  end

  describe '#substract_from_balance' do
    let!(:retailer) { create(:retailer) }
    let!(:retailer_user) { create(:retailer_user, retailer: retailer) }

    let!(:customer1) { create(:customer, retailer: retailer) }
    let!(:customer2) { create(:customer, retailer: retailer) }

    it 'will not substract the retailer\'s ws_conversation_cost from the retailer balance if status is failed' do
      former_retailer_balance = retailer.ws_balance
      create(:karix_whatsapp_message, retailer: retailer, customer: customer1, message_type: 'conversation',
        status: 'failed')

      expect(retailer.reload.ws_balance).to eq(former_retailer_balance)
    end

    it 'will substract the retailer\'s ws_conversation_cost from the retailer balance if message_type is \'conversation\'' do
      former_retailer_balance = retailer.ws_balance
      create(:karix_whatsapp_message, retailer: retailer, customer: customer1, message_type: 'conversation')

      expect(retailer.reload.ws_balance).to eq(former_retailer_balance - retailer.ws_conversation_cost)
    end

    it 'will substract the retailer\'s ws_notification_cost from the retailer balance if message_type is \'notification\'' do
      former_retailer_balance = retailer.ws_balance

      create(:karix_whatsapp_message, retailer: retailer, customer: customer1, message_type: 'notification')
      expect(retailer.reload.ws_balance).to eq(former_retailer_balance - retailer.ws_notification_cost)
    end

    it 'expect not to set ws_next_notification_balance if ws_balance is > 1.5' do
      expect {
        create(:karix_whatsapp_message, retailer: retailer, customer: customer1)
      }.to_not change { retailer.ws_next_notification_balance }
    end

    it 'expect not to send a running out balance notification email if ws_balance is > 1.5' do
      expect {
        create(:karix_whatsapp_message, retailer: retailer, customer: customer1)
      }.to_not change { ActionMailer::Base.deliveries.size }
    end

    context 'if ws_balance <= to the current ws_next_notification_balance and it is > 0' do
      it 'will set ws_next_notification_balance down in -0.5 and send a running out balance notification email' do
        retailer.update_attributes(ws_balance: 1.4)

        expect {
          create(:karix_whatsapp_message, retailer: retailer, customer: customer1)
        }.to change { retailer.ws_next_notification_balance }.by(-0.5).and change { ActionMailer::Base.deliveries.size }.by(1)
      end
    end
  end

  describe '#send_welcome_message' do
    let(:set_karix_messages_service) { Whatsapp::Karix::Messages.new }

    before do
      allow(set_karix_messages_service).to receive(:send_message)
        .and_return(karix_response)
      allow(Whatsapp::Karix::Messages).to receive(:new)
        .and_return(set_karix_messages_service)
    end

    context 'when the retailer does not have an active welcome message configured' do
      let(:retailer) { create(:retailer, :karix_integrated) }
      let(:customer) { create(:customer, retailer: retailer) }

      let(:message) do
        create(:karix_whatsapp_message, :inbound, customer: customer)
      end

      it 'returns nil' do
        expect(message.send(:send_welcome_message)).to be nil
      end
    end

    context 'when the customer does not text for the first time' do
      let!(:automatic_answer) { create(:automatic_answer, :welcome, :whatsapp, retailer: retailer) }
      let(:retailer) { create(:retailer, :karix_integrated) }
      let(:customer) { create(:customer, retailer: retailer) }

      let!(:first_message) do
        create(:karix_whatsapp_message, :inbound, customer: customer)
      end

      let(:message) do
        create(:karix_whatsapp_message, :inbound, customer: customer)
      end

      it 'returns nil' do
        expect(message.send(:send_welcome_message)).to be nil
      end
    end

    context 'when the message is not inbound' do
      let!(:automatic_answer) { create(:automatic_answer, :welcome, :whatsapp, retailer: retailer) }
      let(:retailer) { create(:retailer, :karix_integrated) }
      let(:customer) { create(:customer, retailer: retailer) }

      let(:message) do
        create(:karix_whatsapp_message, :outbound, customer: customer)
      end

      it 'returns nil' do
        expect(message.send(:send_welcome_message)).to be nil
      end
    end

    context 'when all conditions are present' do
      let!(:automatic_answer) { create(:automatic_answer, :welcome, :whatsapp, retailer: retailer) }
      let(:retailer) { create(:retailer, :karix_integrated) }
      let(:customer) { create(:customer, retailer: retailer) }

      let(:message) do
        create(:karix_whatsapp_message, :inbound, customer: customer, retailer: customer.retailer)
      end

      it 'sends the message' do
        expect { message.send(:send_welcome_message) }.to change(KarixWhatsappMessage, :count).by(2)
        expect(KarixWhatsappMessage.last.content_text).to eq(karix_response['objects'][0]['content']['text'])
      end
    end
  end

  describe '#send_inactive_message' do
    let(:set_karix_messages_service) { Whatsapp::Karix::Messages.new }

    before do
      allow(set_karix_messages_service).to receive(:send_message)
        .and_return(karix_response)
      allow(Whatsapp::Karix::Messages).to receive(:new)
        .and_return(set_karix_messages_service)
    end

    context 'when the retailer does not have an inactive message configured' do
      let(:retailer) { create(:retailer, :karix_integrated) }
      let(:customer) { create(:customer, retailer: retailer) }

      let!(:first_message) do
        create(:karix_whatsapp_message, :inbound, customer: customer)
      end

      let(:message) do
        create(:karix_whatsapp_message, :inbound, customer: customer)
      end

      it 'returns nil' do
        expect(message.send(:send_inactive_message)).to be nil
      end
    end

    context 'when the customer does not have a prior message sent' do
      let!(:automatic_answer) { create(:automatic_answer, :inactive, :whatsapp, retailer: retailer) }
      let(:retailer) { create(:retailer, :karix_integrated) }
      let(:customer) { create(:customer, retailer: retailer) }

      let(:message) do
        create(:karix_whatsapp_message, :inbound, customer: customer)
      end

      it 'returns nil' do
        expect(message.send(:send_inactive_message)).to be nil
      end
    end

    context 'when the message is not inbound' do
      let!(:automatic_answer) { create(:automatic_answer, :inactive, :whatsapp, retailer: retailer) }
      let(:retailer) { create(:retailer, :karix_integrated) }
      let(:customer) { create(:customer, retailer: retailer) }

      let!(:first_message) do
        create(:karix_whatsapp_message, :inbound, customer: customer)
      end

      let(:message) do
        create(:karix_whatsapp_message, :outbound, customer: customer)
      end

      it 'returns nil' do
        expect(message.send(:send_inactive_message)).to be nil
      end
    end

    context 'when the created time of the prior message is not passed yet' do
      let!(:automatic_answer) { create(:automatic_answer, :inactive, :whatsapp, retailer: retailer) }
      let(:retailer) { create(:retailer, :karix_integrated) }
      let(:customer) { create(:customer, retailer: retailer) }

      let!(:first_message) do
        create(:karix_whatsapp_message, :inbound, customer: customer, created_at:
          Time.now - 11.hours)
      end

      let(:message) do
        create(:karix_whatsapp_message, :inbound, customer: customer)
      end

      it 'returns nil' do
        expect(message.send(:send_inactive_message)).to be nil
      end
    end

    context 'when all conditions are present' do
      let!(:automatic_answer) { create(:automatic_answer, :inactive, :whatsapp, retailer: retailer) }
      let(:retailer) { create(:retailer, :karix_integrated) }
      let(:customer) { create(:customer, retailer: retailer) }

      let!(:first_message) do
        create(:karix_whatsapp_message, :inbound, retailer: retailer, customer: customer, created_at:
          Time.now - 13.hours)
      end

      let(:message) do
        create(:karix_whatsapp_message, :inbound, customer: customer, retailer: customer.retailer)
      end

      it 'sends the message' do
        expect { message.send(:send_inactive_message) }.to change(KarixWhatsappMessage, :count).by(2)
        expect(KarixWhatsappMessage.last.content_text).to eq(karix_response['objects'][0]['content']['text'])
      end
    end
  end
end
