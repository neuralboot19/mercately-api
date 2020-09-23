require 'rails_helper'

RSpec.describe Whatsapp::Gupshup::V1::EventHandler do
  let(:retailer) { create(:retailer, :gupshup_integrated) }
  let(:customer) { create(:customer, retailer: retailer) }
  let(:retailer_user) { create(:retailer_user, retailer: retailer) }

  let(:text_response) do
    {
      'app': 'AutoSeguro',
      'timestamp': 1600888652637,
      'version': 2,
      'type': 'message',
      'payload': {
        'id': 'ABEGWEFFIjd2AhAvMM18XXh3e-sS4DLNu1V-',
        'source': '584149999999',
        'type': 'text',
        'payload': {
          'text': 'Hola'
        },
        'sender': {
          'phone': '584149999999',
          'name': 'Elvis Olivar',
          'country_code': '58',
          'dial_code': '4149999999'
        }
      },
      'gupshup_whatsapp': {
        'app': 'AutoSeguro',
        'timestamp': 1600888652637,
        'version': 2,
        'type': 'message',
        'payload': {
          'id': 'ABEGWEFFIjd2AhAvMM18XXh3e-sS4DLNu1V-',
          'source': '584149999999',
          'type': 'text',
          'payload': {
            'text': 'Hola'
          },
          'sender': {
            'phone': '584149999999',
            'name': 'Elvis Olivar',
            'country_code': '58',
            'dial_code': '4149999999'
          }
        }
      }
    }.with_indifferent_access
  end

  let(:quick_reply_response) do
    {
      'app': 'AutoSeguro',
      'timestamp': 1600887173517,
      'version': 2,
      'type': 'message',
      'payload': {
        'id': 'ABEGWEFFIjd2AhCnRgbFA6m1QWMxHtQm_z7I',
        'source': '584149999999',
        'type': 'quick_reply',
        'payload': {
          'text': 'Agendar llamada',
          'type': 'button'
        },
        'sender': {
          'phone': '584149999999',
          'name': 'Elvis Olivar',
          'country_code': '58',
          'dial_code': '4149999999'
        },
        'context': {
          'id': 'gBEGWEFFIjd2AglJdPOCe-3HK_U',
          'gsId': '519b2325-3ba7-40f8-9f35-ff5074f64892'
        }
      },
      'gupshup_whatsapp': {
        'app': 'AutoSeguro',
        'timestamp': 1600887173517,
        'version': 2,
        'type': 'message',
        'payload': {
          'id': 'ABEGWEFFIjd2AhCnRgbFA6m1QWMxHtQm_z7I',
          'source': '584149999999',
          'type': 'quick_reply',
          'payload': {
            'text': 'Agendar llamada',
            'type': 'button'
          },
          'sender': {
            'phone': '584149999999',
            'name': 'Elvis Olivar',
            'country_code': '58',
            'dial_code': '4149999999'
          },
          'context': {
            'id': 'gBEGWEFFIjd2AglJdPOCe-3HK_U',
            'gsId': '519b2325-3ba7-40f8-9f35-ff5074f64892'
          }
        }
      }
    }.with_indifferent_access
  end

  let(:message_event_response) do
    {
      'app': 'AutoSeguro',
      'timestamp': 1600888666804,
      'version': 2,
      'type': 'message-event',
      'payload': {
        'id': 'gBEGWEFFIjd2Agna9wZanZnKxtg',
        'gsId': '5336429d-b867-4782-afc1-218aa4639bd3',
        'type': 'read',
        'destination': '584149999999',
        'payload': {
          'ts': 1600888661
        }
      },
      'gupshup_whatsapp': {
        'app': 'AutoSeguro',
        'timestamp': 1600888666804,
        'version': 2,
        'type': 'message-event',
        'payload': {
          'id': 'gBEGWEFFIjd2Agna9wZanZnKxtg',
          'gsId': '5336429d-b867-4782-afc1-218aa4639bd3',
          'type': 'read',
          'destination': '584149999999',
          'payload': {
            'ts': 1600888661
          }
        }
      }
    }.with_indifferent_access
  end

  describe '#process_event!' do
    context 'when it is a message' do
      context 'with text type' do
        it 'will save a new inbound gupshup message' do
          expect {
            described_class.new(retailer, customer).process_event!(text_response)
          }.to change(GupshupWhatsappMessage, :count).by(1)
        end
      end

      context 'with quick_reply type' do
        it 'will save a new inbound gupshup message' do
          expect {
            described_class.new(retailer, customer).process_event!(quick_reply_response)
          }.to change(GupshupWhatsappMessage, :count).by(1)
        end
      end
    end

    context 'when it is a message_event' do
      let(:message) do
        create(:gupshup_whatsapp_message, customer: customer, retailer: retailer, gupshup_message_id:
          '5336429d-b867-4782-afc1-218aa4639bd3', status: 'sent')
      end

      it 'updates an existing message' do
        expect(message.status).to eq('sent')
        described_class.new(retailer, customer).process_event!(message_event_response)
        expect(message.reload.status).to eq('read')
      end
    end
  end
end
