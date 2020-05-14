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
      context 'when the response from Gupshup does not have errors' do
        it 'successfully response a 200 status'
      end

      context 'when the response from Gupshup has errors' do
        it 'fails, response a 500 status'
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

      it 'stores a new customer with whatsapp name' do
        allow_any_instance_of(Customer).to receive(:verify_opt_in).and_return(true)

        expect {
          post '/gupshup/ws',
            params: gupshup_inbound_payload
        }.to change(Customer, :count).by(1)

        expect(response.code).to eq('200')
        inbound_name = gupshup_inbound_payload['gupshup_whatsapp']['payload']['sender']['name']
        expect(Customer.last.whatsapp_name).to eq(inbound_name)
      end

      it 'stores a new gupshup message' do
        allow_any_instance_of(Customer).to receive(:verify_opt_in).and_return(true)

        expect {
          post '/gupshup/ws',
            params: gupshup_inbound_payload
        }.to change(GupshupWhatsappMessage, :count).by(1)

        expect(response.code).to eq('200')
        inbound_text = gupshup_inbound_payload['gupshup_whatsapp']['payload']['payload']['text']
        expect(GupshupWhatsappMessage.last.message_payload['payload']['payload']['text']).to eq(inbound_text)
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
