require 'rails_helper'

RSpec.describe Whatsapp::Gupshup::V1::EventHandler do
  let(:retailer) { create(:retailer, :gupshup_integrated) }
  let(:customer) { create(:customer, retailer: retailer, phone: '58412054XXXX', country_id: 'VE') }
  let(:retailer_user) { create(:retailer_user, retailer: retailer) }

  let(:text_response) do
    {
      'app': 'MySrCName',
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
        'app': 'MySrCName',
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
      'app': 'MySrCName',
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
        'app': 'MySrCName',
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
      'app': 'MySrCName',
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
        'app': 'MySrCName',
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

  let(:number_not_exist_response) do
    {
      'app': 'MySrCName',
      'timestamp': 1616513437223,
      'version': 2,
      'type': 'message-event',
      'payload': {
        'id': 'd6732472-6073-478b-9d16-8ab2e1b042e1',
        'type': 'failed',
        'destination': '58412054XXXX',
        'payload': {
          'code': 1002,
          'reason': 'Number Does Not Exists On WhatsApp'
        }
      },
      'gupshup_whatsapp': {
        'app': 'MySrCName',
        'timestamp': 1616513437223,
        'version': 2,
        'type': 'message-event',
        'payload': {
          'id': 'd6732472-6073-478b-9d16-8ab2e1b042e1',
          'type': 'failed',
          'destination': '58412054XXXX',
          'payload': {
            'code': 1002,
            'reason': 'Number Does Not Exists On WhatsApp'
          }
        }
      }
    }.with_indifferent_access
  end

  describe '#process_event!' do
    context 'when it is a message' do
      before do
        allow_any_instance_of(GupshupWhatsappMessage).to receive(:send_push_notifications).and_return(true)
        allow_any_instance_of(Customer).to receive(:verify_opt_in).and_return(true)
        allow_any_instance_of(Customer).to receive(:opt_in_number_to_use).and_return(true)
      end

      context 'when the customer already exists in DB' do
        let(:customer2) { create(:customer, retailer: retailer, phone: '584149999999', country_id: 'VE') }

        context 'with text type' do
          it 'will save a new inbound gupshup message' do
            expect {
              described_class.new(retailer, customer2).process_event!(text_response)
            }.to change(GupshupWhatsappMessage, :count).by(1)
          end
        end

        context 'with quick_reply type' do
          it 'will save a new inbound gupshup message' do
            expect {
              described_class.new(retailer, customer2).process_event!(quick_reply_response)
            }.to change(GupshupWhatsappMessage, :count).by(1)
          end
        end
      end

      context 'when the customer does not exist in DB yet' do
        before do
          CustomerQueue.destroy_all
          CustomerQueue.create_indexes
          MessageQueue.create_indexes
          allow_any_instance_of(CustomerQueue).to receive(:create_customer).and_return(true)
        end

        context 'with text type' do
          it 'will insert a new customer on queue' do
            expect {
              described_class.new(retailer, nil).process_event!(text_response)
            }.to change(CustomerQueue, :count).by(1)

            cq = CustomerQueue.last
            expect(cq.message_queues.count).to eq(1)
          end
        end

        context 'with quick_reply type' do
          it 'will insert a new customer on queue' do
            expect {
              described_class.new(retailer, nil).process_event!(quick_reply_response)
            }.to change(CustomerQueue, :count).by(1)

            cq = CustomerQueue.last
            expect(cq.message_queues.count).to eq(1)
          end
        end

        context 'when receiving multiple messages at the same time by the same phone number' do
          let!(:retailer2) { create(:retailer, :gupshup_integrated) }

          it 'will enqueued the phone number once and enqueued the messages' do
            CustomerQueue.destroy_all
            expect(CustomerQueue.count).to eq(0)

            arr = (1..8).to_a
            Parallel.each(arr, in_processes: 8) do
              described_class.new(retailer2).process_event!(text_response)
            end

            expect(CustomerQueue.count).to eq(1)
            cq = CustomerQueue.last
            expect(cq.message_queues.count).to eq(8)
          end
        end
      end
    end

    context 'when it is a message_event' do
      let!(:message) do
        create(:gupshup_whatsapp_message, customer: customer, retailer: retailer, gupshup_message_id:
          '5336429d-b867-4782-afc1-218aa4639bd3', status: 'sent')
      end

      it 'does not create a new gupshup message' do
        expect {
          described_class.new(retailer, customer).process_event!(message_event_response)
        }.to change(GupshupWhatsappMessage, :count).by(0)
      end
    end
  end

  describe '#process_error!' do
    context 'when the destination number does not exist on WhatsApp' do
      let!(:message) do
        create(:gupshup_whatsapp_message, customer: customer, retailer: retailer, gupshup_message_id:
          'd6732472-6073-478b-9d16-8ab2e1b042e1', status: 'sent')
      end

      it 'saves the response error on error_payload attribute' do
        expect(message.error_payload).to be_nil

        expect do
          described_class.new(retailer, customer).process_error!(number_not_exist_response)
        end.to change(GupshupWhatsappMessage, :count).by(0)

        error_payload = message.reload.error_payload
        expect(error_payload).not_to be_nil
        expect(error_payload.try(:[], 'payload').try(:[], 'payload').try(:[], 'code')).to eq(1002)
      end
    end
  end
end
