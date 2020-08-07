require 'rails_helper'

RSpec.describe Whatsapp::Karix::Messages do
  subject(:message_service) { described_class.new }

  let(:retailer) { create(:retailer, :karix_integrated) }
  let(:retailer_user) { create(:retailer_user, retailer: retailer) }
  let(:message) { create(:karix_whatsapp_message, account_uid: nil) }

  let(:karix_response) do
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
      'destination': '+593998377063',
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
    }.with_indifferent_access
  end

  describe '.assign_message' do
    context 'when the message has not status yet' do
      let(:message) { create(:karix_whatsapp_message, status: nil) }

      it 'updates the message with the status of the response' do
        expect(message.status).to be nil
        aux_message = message_service.assign_message(message, retailer, karix_response)
        expect(aux_message.status).to eq('queued')
      end
    end

    context 'when the status of the response is a not known status' do
      let(:message) { create(:karix_whatsapp_message, status: 'queued') }

      it 'updates the message with the status of the response' do
        expect(message.status).to eq('queued')
        karix_response['status'] = 'anything'
        aux_message = message_service.assign_message(message, retailer, karix_response)
        expect(aux_message.status).to eq('anything')
      end
    end

    context 'when the status of the response is prior to the current message status' do
      let(:message) { create(:karix_whatsapp_message, status: 'read') }

      it 'does not update the message status' do
        expect(message.status).to eq('read')
        karix_response['status'] = 'sent'
        aux_message = message_service.assign_message(message, retailer, karix_response)
        expect(aux_message.status).to eq('read')
      end
    end

    context 'when the status of the response is greater than the current message status' do
      let(:message) { create(:karix_whatsapp_message, status: 'queued') }

      it 'updates the message with the status of the response' do
        expect(message.status).to eq('queued')
        karix_response['status'] = 'sent'
        aux_message = message_service.assign_message(message, retailer, karix_response)
        expect(aux_message.status).to eq('sent')
      end
    end

    context 'when it is an outbound message' do
      let(:message) { create(:karix_whatsapp_message, status: 'queued', direction: 'outbound', retailer: retailer) }

      it 'assigns the retailer user to the message' do
        aux_message = message_service.assign_message(message, retailer, karix_response, retailer_user)
        expect(aux_message.retailer_user_id).to eq(retailer_user.id)
      end
    end
  end
end
