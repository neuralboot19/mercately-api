require 'rails_helper'

RSpec.describe 'GupshupWhatsappController', type: :request do
  let(:retailer) { create(:retailer, :gupshup_integrated) }
  let(:retailer_user) { create(:retailer_user, :admin, retailer: retailer) }

  describe 'POST #save_message' do
    it 'returns a code 404 if app not found' do
      post '/gupshup/ws',
        params: {
          'gupshup_whatsapp' => {
            'app' => 'wrongAppName',
            'payload' => {
              'type' => 'text'
            }
          }
        }
      body = JSON.parse(response.body)

      expect(response.code).to eq('404')
      expect(body['message']).to eq('Gupshup Whatsapp app not found')
    end

    context 'outbound message events' do
      context 'when the response from Gupshup has errors' do
        let(:customer) { create(:customer, retailer: retailer, phone: '58414522XXXX', country_id: 'VE') }
        let!(:gupshup_message) do
          create(:gupshup_whatsapp_message, customer: customer, retailer: retailer, gupshup_message_id: 'f7fd3d13-bc80-47e4-8697-2f2611a20b70')
        end

        let(:failed_response) do
          {
            'gupshup_whatsapp': {
              'app': retailer.gupshup_src_name,
              'timestamp': 159_127_605_500_0,
              'version': 2,
              'type': 'message-event',
              'payload': {
                'id': 'f7fd3d13-bc80-47e4-8697-2f2611a20b70',
                'type': 'failed',
                'destination': '58414522XXXX',
                'payload': {
                  'code': 1005,
                  'reason': 'Message sending failed as user is inactive for session message and template did not match'
                }
              }
            }
          }
        end
        it 'fails, updates the message and returns ok' do
          post '/gupshup/ws', params: failed_response

          expect(gupshup_message.status).to eq('submitted')
          expect(response.code).to eq('200')
          expect(gupshup_message.reload.status).to eq('error')
        end
      end

      context 'when the appName requested from Gupshup does not exist' do
        it 'fails, response a 404 status'
      end
    end

    context 'inbound message' do
      let(:gupshup_inbound_payload) do
        {
          'gupshup_whatsapp' => {
            'app' => retailer.gupshup_src_name,
            'timestamp' => 1589374987521,
            'version' => 2,
            'type' => 'message',
            'payload' => {
              'id' => 'ABEGWTmYN3BjAhBVDvUy9JyUgNNjdKvZWRFT',
              'source' => '593999999999',
              'type' => 'text',
              'payload' => {
                'text' => 'Hi'
              },
              'sender' => {
                'phone' => '593999999999',
                'name' => 'bj',
                'country_code' => '593',
                'dial_code' => '998377063'
              }
            }
          }
        }
      end

      context 'when 52 mexican number' do
        let(:gupshup_inbound_payload) do
          {
            'gupshup_whatsapp' => {
              'app' => retailer.gupshup_src_name,
              'timestamp' => 1589374987521,
              'version' => 2,
              'type' => 'message',
              'payload' => {
                'id' => 'ABEGWTmYN3BjAhBVDvUy9JyUgNNjdKvZWRFT',
                'source' => '525599999999',
                'type' => 'text',
                'payload' => {
                  'text' => 'Hi'
                },
                'sender' => {
                  'phone' => '525599999999',
                  'name' => 'bj',
                  'country_code' => '52',
                  'dial_code' => '5599999999'
                }
              }
            }
          }
        end

        it 'adds the 1 char' do
          allow_any_instance_of(Customer).to receive(:verify_opt_in).and_return(true)
          allow_any_instance_of(Customer).to receive(:opt_in_number_to_use).and_return(true)

          expect {
            post '/gupshup/ws',
            params: gupshup_inbound_payload
          }.to change(Customer, :count).by(1)

          expect(response.code).to eq('200')
          expect(Customer.last.phone).to eq '+5215599999999'
        end

        it 'saves the original phone as number to use' do
          allow_any_instance_of(Customer).to receive(:verify_opt_in).and_return(true)
          allow_any_instance_of(Customer).to receive(:opt_in_number_to_use).and_return(true)

          expect {
            post '/gupshup/ws',
            params: gupshup_inbound_payload
          }.to change(Customer, :count).by(1)

          expect(response.code).to eq('200')
          expect(Customer.last.number_to_use).to eq '+525599999999'
        end
      end

      context 'when 521 mexican number' do
        let(:gupshup_inbound_payload) do
          {
            'gupshup_whatsapp' => {
              'app' => retailer.gupshup_src_name,
              'timestamp' => 1589374987521,
              'version' => 2,
              'type' => 'message',
              'payload' => {
                'id' => 'ABEGWTmYN3BjAhBVDvUy9JyUgNNjdKvZWRFT',
                'source' => '5215599999999',
                'type' => 'text',
                'payload' => {
                  'text' => 'Hi'
                },
                'sender' => {
                  'phone' => '5215599999999',
                  'name' => 'bj',
                  'country_code' => '52',
                  'dial_code' => '15599999999'
                }
              }
            }
          }
        end

        it 'maintains the same number' do
          allow_any_instance_of(Customer).to receive(:verify_opt_in).and_return(true)
          allow_any_instance_of(Customer).to receive(:opt_in_number_to_use).and_return(true)

          expect {
            post '/gupshup/ws',
            params: gupshup_inbound_payload
          }.to change(Customer, :count).by(1)

          expect(response.code).to eq('200')
          expect(Customer.last.phone).to eq '+5215599999999'
        end

        it 'saves the original phone' do
          allow_any_instance_of(Customer).to receive(:verify_opt_in).and_return(true)
          allow_any_instance_of(Customer).to receive(:opt_in_number_to_use).and_return(true)

          expect {
            post '/gupshup/ws',
            params: gupshup_inbound_payload
          }.to change(Customer, :count).by(1)

          expect(response.code).to eq('200')
          expect(Customer.last.number_to_use).to be_nil
        end
      end

      context 'when not mexican number' do
        it 'maintains the same number' do
          allow_any_instance_of(Customer).to receive(:verify_opt_in).and_return(true)
          allow_any_instance_of(Customer).to receive(:opt_in_number_to_use).and_return(true)

          expect {
            post '/gupshup/ws',
            params: gupshup_inbound_payload
          }.to change(Customer, :count).by(1)

          expect(response.code).to eq('200')
          expect(Customer.last.phone).to eq '+593998377063'
        end

        it 'does not save the original phone' do
          allow_any_instance_of(Customer).to receive(:verify_opt_in).and_return(true)
          allow_any_instance_of(Customer).to receive(:opt_in_number_to_use).and_return(true)

          expect {
            post '/gupshup/ws',
            params: gupshup_inbound_payload
          }.to change(Customer, :count).by(1)

          expect(response.code).to eq('200')
          expect(Customer.last.number_to_use).to be_nil
        end
      end

      context 'when 521 Mexican phone already registered in DB' do
        let(:gupshup_inbound_payload) do
          {
            'gupshup_whatsapp' => {
              'app' => retailer.gupshup_src_name,
              'timestamp' => 1589374987521,
              'version' => 2,
              'type' => 'message',
              'payload' => {
                'id' => 'ABEGWTmYN3BjAhBVDvUy9JyUgNNjdKvZWRFT',
                'source' => '525599999999',
                'type' => 'text',
                'payload' => {
                  'text' => 'Hi'
                },
                'sender' => {
                  'phone' => '525599999999',
                  'name' => 'bj',
                  'country_code' => '52',
                  'dial_code' => '5599999999'
                }
              }
            }
          }
        end

        let!(:customer) { create(:customer, retailer: retailer, phone: '+5215599999999', country_id: 'MX') }

        it 'does not create a new customer' do
          allow_any_instance_of(Customer).to receive(:verify_opt_in).and_return(true)
          allow_any_instance_of(Customer).to receive(:opt_in_number_to_use).and_return(true)

          expect {
            post '/gupshup/ws',
            params: gupshup_inbound_payload
          }.to change(Customer, :count).by(0)
        end

        it 'saves the original phone as number to use' do
          allow_any_instance_of(Customer).to receive(:verify_opt_in).and_return(true)
          allow_any_instance_of(Customer).to receive(:opt_in_number_to_use).and_return(true)

          expect(customer.number_to_use).to be_nil

          expect {
            post '/gupshup/ws',
            params: gupshup_inbound_payload
          }.to change(Customer, :count).by(0)

          expect(customer.reload.number_to_use).to eq('+525599999999')
        end
      end

      context 'when 52 Mexican phone already registered in DB' do
        let(:gupshup_inbound_payload) do
          {
            'gupshup_whatsapp' => {
              'app' => retailer.gupshup_src_name,
              'timestamp' => 1589374987521,
              'version' => 2,
              'type' => 'message',
              'payload' => {
                'id' => 'ABEGWTmYN3BjAhBVDvUy9JyUgNNjdKvZWRFT',
                'source' => '5215599999999',
                'type' => 'text',
                'payload' => {
                  'text' => 'Hi'
                },
                'sender' => {
                  'phone' => '5215599999999',
                  'name' => 'bj',
                  'country_code' => '52',
                  'dial_code' => '5599999999'
                }
              }
            }
          }
        end

        let!(:customer) { create(:customer, retailer: retailer, phone: '+525599999999', country_id: 'MX') }

        it 'does not create a new customer' do
          allow_any_instance_of(Customer).to receive(:verify_opt_in).and_return(true)
          allow_any_instance_of(Customer).to receive(:opt_in_number_to_use).and_return(true)

          expect {
            post '/gupshup/ws',
            params: gupshup_inbound_payload
          }.to change(Customer, :count).by(0)
        end

        it 'does not save the original phone as number to use' do
          allow_any_instance_of(Customer).to receive(:verify_opt_in).and_return(true)

          expect(customer.number_to_use).to be_nil

          expect {
            post '/gupshup/ws',
            params: gupshup_inbound_payload
          }.to change(Customer, :count).by(0)

          expect(customer.reload.number_to_use).to be_nil
        end
      end

      it 'stores a new customer with whatsapp name' do
        allow_any_instance_of(Customer).to receive(:verify_opt_in).and_return(true)
        allow_any_instance_of(Customer).to receive(:opt_in_number_to_use).and_return(true)

        expect {
          post '/gupshup/ws',
            params: gupshup_inbound_payload
        }.to change(Customer, :count).by(1)

        expect(response.code).to eq('200')
        inbound_name = gupshup_inbound_payload['gupshup_whatsapp']['payload']['sender']['name']
        expect(Customer.last.whatsapp_name).to eq(inbound_name)
      end

      context 'when the customer already exists in DB' do
        let!(:customer) { create(:customer, retailer: retailer, phone: '+593999999999') }

        it 'stores a new gupshup message' do
          allow_any_instance_of(GupshupWhatsappMessage).to receive(:send_push_notifications).and_return(true)
          allow_any_instance_of(Customer).to receive(:verify_opt_in).and_return(true)
          allow_any_instance_of(Customer).to receive(:opt_in_number_to_use).and_return(true)

          expect {
            post '/gupshup/ws',
              params: gupshup_inbound_payload
          }.to change(GupshupWhatsappMessage, :count).by(1)

          expect(response.code).to eq('200')
          inbound_text = gupshup_inbound_payload['gupshup_whatsapp']['payload']['payload']['text']
          expect(GupshupWhatsappMessage.last.message_payload['payload']['payload']['text']).to eq(inbound_text)
        end
      end

      context 'when the customer does not exist in DB yet' do
        it 'will insert a new customer on queue' do
          allow_any_instance_of(GupshupWhatsappMessage).to receive(:send_push_notifications).and_return(true)
          allow_any_instance_of(Customer).to receive(:verify_opt_in).and_return(true)
          allow_any_instance_of(Customer).to receive(:opt_in_number_to_use).and_return(true)

          expect {
            post '/gupshup/ws',
              params: gupshup_inbound_payload
          }.to change(CustomerQueue, :count).by(1)

          cq = CustomerQueue.last
          expect(cq.message_queues.count).to eq(1)
          expect(response.code).to eq('200')
        end
      end

      it 'returns a code 200 if type is sandbox-start' do
        gupshup_inbound_payload['gupshup_whatsapp']['payload']['type'] = 'sandbox-start'

        post '/gupshup/ws',
          params: gupshup_inbound_payload

        expect(response.code).to eq('200')
      end

      it 'returns a 500 if request payload is mal formed' do
        gupshup_wrong_payload = {
          '_json': 'None',
          'action': 'save_message',
          'controller': 'gupshup_whatsapp',
          'gupshup_whatsapp': {
            _json: 'None'
          }
        }

        post '/gupshup/ws',
          params: gupshup_wrong_payload

        expect(response.code).to eq('500')
      end
    end
  end
end
