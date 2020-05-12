require 'rails_helper'

RSpec.describe 'Api::V1::KarixWhatsappController', type: :request do
  let(:retailer) { create(:retailer, :karix_integrated) }
  let(:retailer_user) { create(:retailer_user, :admin, retailer: retailer) }

  let(:customer1) { create(:customer, retailer: retailer) }
  let(:customer2) { create(:customer, retailer: retailer) }

  before do
    # Whatsapp messages for customer1 and customer2
    create_list(:karix_whatsapp_message, 6, retailer: retailer, customer: customer1)
    create_list(:karix_whatsapp_message, 6, retailer: retailer, customer: customer2)

    sign_in retailer_user
  end

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

  let(:karix_data) do
    {
      "account_id" => retailer.id,
      'data' => {
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
    }
  end

  describe 'GET #index' do
    it 'responses with all customers' do
      get api_v1_karix_customers_path
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body['customers'].count).to eq(2)
    end

    it 'filters customers by first_name' do
      get api_v1_karix_customers_path, params: { customerSearch: customer2.first_name }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body['customers'].count).to eq(1)
      expect(body['customers'][0]).to include(customer2.slice(:id, :email, :first_name, :last_name))
    end

    it 'filters customers by last_name' do
      get api_v1_karix_customers_path, params: { customerSearch: customer2.last_name }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body['customers'].count).to eq(1)
      expect(body['customers'][0]).to include(customer2.slice(:id, :email, :first_name, :last_name))
    end

    it 'filters customers by first_name and last_name' do
      get api_v1_karix_customers_path, params: { customerSearch: "#{customer2.first_name} #{customer2.last_name}" }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body['customers'].count).to eq(1)
      expect(body['customers'][0]).to include(customer2.slice(:id, :email, :first_name, :last_name))
    end

    it 'filters customers by email' do
      get api_v1_karix_customers_path, params: { customerSearch: customer1.email }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body['customers'].count).to eq(1)
      expect(body['customers'][0]).to include(customer1.slice(:id, :email, :first_name, :last_name))
    end

    it 'filters customers by phone' do
      get api_v1_karix_customers_path, params: { customerSearch: customer1.phone }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body['customers'].count).to eq(1)
      expect(body['customers'][0]).to include(customer1.slice(:id, :email, :first_name, :last_name))
    end

    it 'responses with a 404 when no customers registered' do
      retailer.customers.destroy_all

      get api_v1_karix_customers_path
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:not_found)
      expect(body['message']).to eq('Customers not found')
      expect(body['customers']).to eq([])
    end

    context 'when the retailer user is an agent' do
      let(:retailer_user_agent) { create(:retailer_user, :with_retailer, :agent, retailer: retailer) }
      let!(:agent_customer1) { create(:agent_customer, retailer_user: retailer_user, customer: customer1) }
      let!(:agent_customer2) { create(:agent_customer, retailer_user: retailer_user_agent, customer: customer2) }

      before do
        sign_out retailer_user
        sign_in retailer_user_agent
      end

      it 'returns only the customers assigned to it or those not assigned' do
        get api_v1_karix_customers_path
        body = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(body['customers'].count).to eq(1)
      end
    end

    context 'when the retailer user does not have customers' do
      before do
        retailer.karix_whatsapp_messages.delete_all
      end

      it 'fails, a 404 Error will be responsed' do
        get api_v1_karix_customers_path
        body = JSON.parse(response.body)

        expect(response.code).to eq('404')
        expect(body['message']).to eq('Customers not found')
      end
    end
  end

  describe 'POST #create' do
    subject { Whatsapp::Karix::Messages }

    let(:message) { create(:karix_whatsapp_message) }

    context 'when the message is sent without errors' do
      it 'successfully, will response a 200 status' do
        allow_any_instance_of(subject).to receive(:send_message).and_return(karix_successful_response)
        allow_any_instance_of(subject).to receive(:assign_message).and_return(message)

        post '/api/v1/karix_send_whatsapp_message',
          params: {
            customer_id: customer1.id,
            message: 'New whatsapp message'
          }

        body = JSON.parse(response.body)
        expect(response.code).to eq('200')
        expect(body['message']).to eq(karix_successful_response['objects'][0])
      end
    end

    context 'when the message is not sent' do
      it 'fails and will response a 500 status' do
        allow_any_instance_of(subject).to receive(:send_message).and_return({ 'error': { 'message':
          'Connection rejected' }}.with_indifferent_access)

        post '/api/v1/karix_send_whatsapp_message',
          params: {
            customer_id: customer1.id,
            message: 'New whatsapp message'
          }

        body = JSON.parse(response.body)
        expect(response.code).to eq('500')
        expect(body['message']).to eq('Connection rejected')
      end
    end

    context 'because of the retailer has not enough balance' do
      it 'fails and will response a 401 status' do
        retailer.update_attributes(ws_balance: 0.0671)

        post '/api/v1/karix_send_whatsapp_message',
          params: {
            customer_id: customer1.id,
            message: 'New whatsapp message'
          }

        body = JSON.parse(response.body)
        expect(response.code).to eq('401')
        expect(body['message']).to eq('Usted no tiene suficiente saldo para enviar mensajes de Whatsapp, '\
                                      'por favor, contáctese con su agente de ventas para recargar su saldo')
      end
    end
  end

  describe 'GET #messages' do
    context 'when the customer selected has messages' do
      it 'successfully response a 200 status' do
        get "/api/v1/karix_whatsapp_customers/#{customer1.id}/messages"
        body = JSON.parse(response.body)

        expect(response.code).to eq('200')
        expect(body['messages'].count).to eq(6)
      end

      context 'but retailer has not enough balance' do
        it 'responses a 401 status' do
          retailer.update_attributes(ws_balance: 0.0671)

          get "/api/v1/karix_whatsapp_customers/#{customer1.id}/messages"
          body = JSON.parse(response.body)

          expect(response.code).to eq('401')
          expect(body['messages'].count).to eq(6)
          expect(body['balance_error_info']['status']).to eq(401)
          expect(body['balance_error_info']['message']).to eq('Usted no tiene suficiente saldo para enviar mensajes de Whatsapp, '\
                                                              'por favor, contáctese con su agente de ventas para recargar su saldo')
        end
      end
    end

    context 'when the customer selected does not have messages' do
      let(:customer3) { create(:customer) }

      it 'fails, response a 404 status' do
        get "/api/v1/karix_whatsapp_customers/#{customer3.id}/messages"
        body = JSON.parse(response.body)

        expect(response.code).to eq('404')
        expect(body['message']).to eq('Messages not found')
      end
    end
  end

  describe 'POST #save_message' do
    context 'when the response from Karix does not have errors' do
      it 'successfully response a 200 status' do
        post "/api/v1/karix_whatsapp",
          params: karix_data

        body = JSON.parse(response.body)

        expect(response.code).to eq('200')
        expect(body['message']).to eq('Succesful')
      end
    end

    context 'when the response from Karix has errors' do
      it 'fails, response a 500 status' do
        post "/api/v1/karix_whatsapp",
          params: {
            error: {
              message: 'Connection rejected'
            }
          }

        body = JSON.parse(response.body)

        expect(response.code).to eq('500')
        expect(body['message']).to eq('Connection rejected')
      end
    end

    context 'when the retailer requested from Karix does not exist' do
      it 'fails, response a 404 status' do
        karix_data['account_id'] = nil

        post "/api/v1/karix_whatsapp",
          params: karix_data

        body = JSON.parse(response.body)

        expect(response.code).to eq('404')
        expect(body['message']).to eq('Account not found')
      end
    end
  end

  describe 'POST #send_file' do
    subject { Whatsapp::Karix::Messages }

    let(:message) { create(:karix_whatsapp_message) }

    context 'when the message is sent without errors' do
      it 'successfully, will response a 200 status' do
        allow_any_instance_of(subject).to receive(:send_message).and_return(karix_successful_response)
        allow_any_instance_of(subject).to receive(:assign_message).and_return(message)

        post "/api/v1/karix_whatsapp_send_file/#{customer1.id}",
          params: {
            file_data: fixture_file_upload(Rails.root + 'spec/fixtures/profile.jpg', 'image/jpeg')
          }

        body = JSON.parse(response.body)
        expect(response.code).to eq('200')
        expect(body['message']).to eq(karix_successful_response['objects'][0])
      end
    end

    context 'when the message is not sent' do
      it 'fails, will response a 500 status' do
        allow_any_instance_of(subject).to receive(:send_message).and_return({ 'error': { 'message':
          'Connection rejected' }}.with_indifferent_access)

        post "/api/v1/karix_whatsapp_send_file/#{customer1.id}",
          params: {
            file_data: fixture_file_upload(Rails.root + 'spec/fixtures/profile.jpg', 'image/jpeg')
          }

        body = JSON.parse(response.body)
        expect(response.code).to eq('500')
        expect(body['message']).to eq('Connection rejected')
      end
    end
  end

  describe 'PUT #message_read' do
    let(:message) { create(:karix_whatsapp_message, customer: customer1, status: 'delivered') }

    context 'when the message is updated without errors' do
      it 'successfully, will response a 200 status' do
        put "/api/v1/karix_whatsapp_update_message_read/#{customer1.id}",
          params: {
            message_id: message.id
          }

        body = JSON.parse(response.body)
        expect(response.code).to eq('200')
        expect(body['message']['status']).to eq('read')
      end
    end

    context 'when the message is not updated because of errors' do
      it 'will response a 500 status' do
        allow_any_instance_of(KarixWhatsappMessage).to receive(:update_column).and_return(false)

        put "/api/v1/karix_whatsapp_update_message_read/#{customer1.id}",
          params: {
            message_id: message.id
          }

        body = JSON.parse(response.body)
        expect(response.code).to eq('500')
        expect(body['message']).to eq('Error al actualizar mensajes')
      end
    end
  end

  describe 'GET #fast_answers_for_whatsapp' do
    before do
      create_list(:template, 3, :for_whatsapp, retailer: retailer)
      create_list(:template, 2, :for_messenger, retailer: retailer)
      create_list(:template, 2, :for_whatsapp, retailer: retailer, title: 'Texto de prueba')
      create(:template, :for_whatsapp, retailer: retailer, answer: 'Contenido de prueba')
    end

    it 'returns a whatsapp fast answers list' do
      get api_v1_fast_answers_for_whatsapp_path
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body['templates']['data'].count).to eq(6)
    end

    it 'filters by title' do
      get api_v1_fast_answers_for_whatsapp_path, params: { search: 'texto' }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body['templates']['data'].count).to eq(2)
      expect(body['templates']['data'][0]['attributes']['title']).to include('Texto')
    end

    it 'filters by content' do
      get api_v1_fast_answers_for_whatsapp_path, params: { search: 'contenido' }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body['templates']['data'].count).to eq(1)
      expect(body['templates']['data'][0]['attributes']['answer']).to include('Contenido')
    end
  end
end
