require 'rails_helper'

RSpec.describe 'Retailers::Api::V1::KarixWhatsappController', type: :request do
  describe 'POST #create' do
    let(:retailer) { create(:retailer) }
    let(:retailer_user) { create(:retailer_user, retailer: retailer, email: 'retailer@example.com') }
    let!(:customer) { create(:customer, retailer: retailer) }

    # Generating credentials for the retailer
    let(:slug) { retailer_user.retailer.slug }
    let(:api_key) { retailer_user.retailer.generate_api_key }

    # Responses
    let(:karix_successful_response) do
      {
        'meta' => {
          'request_uuid' => '01678427-c79f-48f7-bf03-b04659611c2e',
          'available_credits' => '1.51226',
          'credits_charged' => '0.004'
        },
        'objects'=>[
          {
            'account_uid' => '3a9f05a1-4e59-4504-9ca9-be9ec1934f2b',
            'channel'=>'whatsapp',
            'channel_details' => {
              'whatsapp' => {
                'platform_fee' => '0.004',
                'type'=>'conversation',
                'whatsapp_fee'=>'0'
              }
            },
            'content' => {
              'text' => 'New Whatsapp message'
            },
            'content_type' => 'text',
            'country' => 'EC',
            'created_time' => '2020-03-18T15:01:14.624018Z',
            'delivered_time' => nil,
            'destination' => '+593998377063',
            'direction' => 'outbound',
            'error' => nil,
            'redact' => false,
            'refund' => nil,
            'sent_time' => nil,
            'source' => '+13253077759',
            'status' => 'queued',
            'total_cost' => '0.004',
            'uid' => '87f3c742-95e3-4bb3-a671-cce2705e1a21',
            'updated_time' => nil
          }
        ]
      }
    end

    let(:karix_error_response) do
      {
        "meta" => {
          "request_uuid" => "ed0e8c65-1b72-4100-80c7-0d344abdfd36",
          "available_credits" => "1.51226",
          "credits_charged" => "0"
        },
        'objects' => [
          {
            'account_uid' => '3a9f05a1-4e59-4504-9ca9-be9ec1934f2b',
            'channel' => 'whatsapp',
            'channel_details' => {
              'whatsapp' => {
                'platform_fee' => '0',
                'type' => 'notification',
                'whatsapp_fee' => '0'
              }
            },
            'content' => {
              'text' => 'New Whatsapp message'
            },
            'content_type' => 'text',
            'country' => 'EC',
            'created_time' => '2020-03-18T16:05:21.529993Z',
            'delivered_time' => nil,
            'destination' => '+5939983770633',
            'direction' => 'outbound',
            'error' => {
              'code' => '1102',
              'message' => 'For whatsapp channel, \'destination\' param should be a sandbox number. Contact sales to remove all restrictions'
            },
            'redact' => false,
            'refund' => nil,
            'sent_time' => nil,
            'source' => '+13253077759',
            'status' => 'failed',
            'total_cost' => '0',
            'uid' => '0629d302-d9d6-4fbe-afa5-2c4a504f24e6',
            'updated_time' => nil
         }
       ]
     }
    end

    context 'when Karix responses' do
      subject { Whatsapp::Karix::Messages }

      it 'successfully, a 200 Ok will be responsed' do
        # Stubbing the respose from Karix
        allow_any_instance_of(subject).to receive(:send_message).and_return(karix_successful_response)

        # Making the request
        post '/retailers/api/v1/whatsapp/send_notification',
             params: {
               phone_number: '+5939983770633',
               message: 'My Message Text'
             },
             headers: {
               'Slug': slug,
               'Api-Key': api_key
             }
        expect(response.code).to eq('200')

        # Once the response is 200 the message should be 'Ok' and the Karix status 'queued'
        body = JSON.parse(response.body)

        expect(body['message']).to eq('Ok')
        expect(body['info']['status']).to eq('queued')
      end

      it 'with an error, a 500 Internal Server Error will be responsed' do
        # Stubbing the respose from Karix
        allow_any_instance_of(subject).to receive(:send_message).and_return(karix_error_response)

        # Making the request
        post '/retailers/api/v1/whatsapp/send_notification',
             params: {
               customer_id: customer.id,
               phone_number: '+5939983770633',
               message: 'My Message Text'
             },
             headers: {
               'Slug': slug,
               'Api-Key': api_key
             }
        expect(response.code).to eq('500')

        # Once the response is 200 the message should be 'Ok' and the Karix status 'queued'
        body = JSON.parse(response.body)

        expect(body['message']).to eq('Error')
        expect(body['info']).to eq(karix_error_response['objects'][0]['error'])
      end

      it 'responses a 500 Internal Server Error response if raises an ActiveRecord exception' do
        # Stubbing the respose from Karix
        allow_any_instance_of(subject).to receive(:send_message).and_return(karix_successful_response)

        # stub the ActiveRecord::RecordInvalid
        allow_any_instance_of(KarixWhatsappMessage).to receive(:save) do |instance|
          instance.errors.add(:base, 'test error')
          raise(ActiveRecord::RecordInvalid, instance)
        end

        # Making the request
        post '/retailers/api/v1/whatsapp/send_notification',
             params: {
               phone_number: '+5939983770633',
               message: 'My Message Text'
             },
             headers: {
               'Slug': slug,
               'Api-Key': api_key
             }

        expect(response.code).to eq('400')
        body = JSON.parse(response.body)
        expect(body['message']).to eq(["test error"])
      end
    end

    it 'responses a 500 Internal Server Error response if phone_number NOT present' do
      # Making the request
      post '/retailers/api/v1/whatsapp/send_notification',
           params: {
             message: 'My Message Text'
           },
           headers: {
             'Slug': slug,
             'Api-Key': api_key
           }
      expect(response.code).to eq('500')

      body = JSON.parse(response.body)
      expect(body['message']).to eq('Error: Missing phone number and/or message')
    end

    it 'responses a 500 Internal Server Error response if message NOT present' do
      # Making the request
      post '/retailers/api/v1/whatsapp/send_notification',
           params: {
            phone_number: '+5939983770633',
           },
           headers: {
             'Slug': slug,
             'Api-Key': api_key
           }
      expect(response.code).to eq('500')

      body = JSON.parse(response.body)
      expect(body['message']).to eq('Error: Missing phone number and/or message')
    end

    it 'responses with a 401 Internal Server Error response if retailer has not enough Whatsapp balance' do
      retailer.update_attributes(ws_balance: 0.0671)

      # Making the request
      post '/retailers/api/v1/whatsapp/send_notification',
           params: {
             phone_number: '+5939983770633',
             message: 'My Message Text'
           },
           headers: {
             'Slug': slug,
             'Api-Key': api_key
           }
      expect(response.code).to eq('401')

      body = JSON.parse(response.body)
      expect(body['message']).to eq('Usted no tiene suficiente saldo para enviar mensajes de Whatsapp, '\
                                    'por favor, contáctese con su agente de ventas para recargar su saldo')
    end

    it 'responses a 500 Internal Server Error response if raises an exception' do
      allow(KarixNotificationHelper).to receive(:ws_message_service).and_return(Exception)

      # Making the request
      post '/retailers/api/v1/whatsapp/send_notification',
           params: {
             phone_number: '+5939983770633',
             message: 'My Message Text'
           },
           headers: {
             'Slug': slug,
             'Api-Key': api_key
           }
      expect(response.code).to eq('500')

      body = JSON.parse(response.body)
      expect(body['message']).to eq("undefined method `send_message' for Exception:Class")
    end
  end
end

