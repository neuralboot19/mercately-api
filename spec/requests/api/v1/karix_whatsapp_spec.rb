require 'rails_helper'

RSpec.describe 'Api::V1::KarixWhatsappController', type: :request do
  let(:retailer) { create(:retailer, :karix_integrated) }
  let(:retailer_user) { create(:retailer_user, :admin, retailer: retailer) }
  let(:retailer_gupshup) { create(:retailer, :gupshup_integrated) }
  let(:retailer_user_gupshup) { create(:retailer_user, :admin, retailer: retailer_gupshup) }

  let(:customer1) { create(:customer, retailer: retailer, first_name: 'Pedro', last_name: 'Perez') }
  let(:customer2) { create(:customer, retailer: retailer, first_name: 'Jane', last_name: 'Doe') }
  let(:customer3) { create(:customer, retailer: retailer_gupshup, first_name: 'Carlos', last_name: 'Gil') }

  before do
    # Whatsapp messages for customer1 and customer2
    create_list(:karix_whatsapp_message, 2, :inbound, retailer: retailer, customer: customer1, status: 'received')
    create_list(:karix_whatsapp_message, 2, :inbound, retailer: retailer, customer: customer1, status: 'read')
    create_list(:karix_whatsapp_message, 2, :outbound, retailer: retailer, customer: customer1, status: 'delivered')
    create_list(:karix_whatsapp_message, 2, :inbound, retailer: retailer, customer: customer1, status: 'failed')
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
          'destination' => '+593998999999',
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

  let(:karix_outbound_data_event) do
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
        'destination' => '+5939989999993',
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
    context 'when local request' do
      it 'responses with all customers' do
        get api_v1_karix_customers_path
        body = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(body['customers'].count).to eq(2)
      end

      it 'filters customers by first_name' do
        get api_v1_karix_customers_path, params: { searchString: customer2.first_name }
        body = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(body['customers'].count).to eq(1)
        expect(body['customers'][0]).to include(customer2.slice(:id, :email, :first_name, :last_name))
      end

      it 'filters customers by last_name' do
        get api_v1_karix_customers_path, params: { searchString: customer2.last_name }
        body = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(body['customers'].count).to eq(1)
        expect(body['customers'][0]).to include(customer2.slice(:id, :email, :first_name, :last_name))
      end

      it 'filters customers by first_name and last_name' do
        get api_v1_karix_customers_path, params: { searchString: "#{customer2.first_name} #{customer2.last_name}" }
        body = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(body['customers'].count).to eq(1)
        expect(body['customers'][0]).to include(customer2.slice(:id, :email, :first_name, :last_name))
      end

      it 'filters customers by email' do
        get api_v1_karix_customers_path, params: { searchString: customer1.email }
        body = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(body['customers'].count).to eq(1)
        expect(body['customers'][0]).to include(customer1.slice(:id, :email, :first_name, :last_name))
      end

      it 'filters customers by phone' do
        get api_v1_karix_customers_path, params: { searchString: customer1.phone }
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

      context 'when the tag filter is present' do
        context 'when the tag filter is "all"' do
          let!(:tag) { create(:tag, retailer: retailer) }
          let!(:customer_tag) { create(:customer_tag, tag: tag, customer: customer1) }

          it 'responses the customers with (any tag assigned/without tags assigned)' do
            get api_v1_karix_customers_path, params: { tag: 'all' }
            body = JSON.parse(response.body)

            expect(response).to have_http_status(:ok)
            expect(body['customers'].count).to eq(2)
          end
        end

        context 'when the tag filter is not "all"' do
          let(:tag) { create(:tag, retailer: retailer) }
          let!(:customer_tag) { create(:customer_tag, tag: tag, customer: customer1) }

          it 'responses only the customers with the tag assigned' do
            get api_v1_karix_customers_path, params: { tag: tag.id }
            body = JSON.parse(response.body)

            expect(response).to have_http_status(:ok)
            expect(body['customers'].count).to eq(1)
          end
        end
      end
    end

    context 'when mobile request' do
      before do
        sign_out retailer_user
      end

      let(:mobile_token) { create(:mobile_token, retailer_user: retailer_user) }

      let(:header_email) { retailer_user.email }
      let(:header_device) { mobile_token.device }
      let(:header_token) { mobile_token.generate! }

      it 'responses with all customers' do
        get api_v1_karix_customers_path, headers: { 'email': header_email, 'device': header_device, 'token': header_token }
        body = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(body['customers'].count).to eq(2)
      end

      it 'filters customers by first_name' do
        get api_v1_karix_customers_path,
            params: { searchString: customer2.first_name },
            headers: { 'email': header_email, 'device': header_device, 'token': header_token }

        body = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(body['customers'].count).to eq(1)
        expect(body['customers'][0]).to include(customer2.slice(:id, :email, :first_name, :last_name))
      end

      it 'filters customers by last_name' do
        get api_v1_karix_customers_path,
            params: { searchString: customer2.last_name },
            headers: { 'email': header_email, 'device': header_device, 'token': header_token }

        body = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(body['customers'].count).to eq(1)
        expect(body['customers'][0]).to include(customer2.slice(:id, :email, :first_name, :last_name))
      end

      it 'filters customers by first_name and last_name' do
        get api_v1_karix_customers_path,
            params: { searchString: "#{customer2.first_name} #{customer2.last_name}" },
            headers: { 'email': header_email, 'device': header_device, 'token': header_token }

        body = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(body['customers'].count).to eq(1)
        expect(body['customers'][0]).to include(customer2.slice(:id, :email, :first_name, :last_name))
      end

      it 'filters customers by email' do
        get api_v1_karix_customers_path,
            params: { searchString: customer1.email },
            headers: { 'email': header_email, 'device': header_device, 'token': header_token }

        body = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(body['customers'].count).to eq(1)
        expect(body['customers'][0]).to include(customer1.slice(:id, :email, :first_name, :last_name))
      end

      it 'filters customers by phone' do
        get api_v1_karix_customers_path,
            params: { searchString: customer1.phone },
            headers: { 'email': header_email, 'device': header_device, 'token': header_token }

        body = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(body['customers'].count).to eq(1)
        expect(body['customers'][0]).to include(customer1.slice(:id, :email, :first_name, :last_name))
      end

      it 'responses with a 404 when no customers registered' do
        retailer.customers.destroy_all

        get api_v1_karix_customers_path, headers: { 'email': header_email, 'device': header_device, 'token': header_token }
        body = JSON.parse(response.body)

        expect(response).to have_http_status(:not_found)
        expect(body['message']).to eq('Customers not found')
        expect(body['customers']).to eq([])
      end

      context 'when the retailer user is an agent' do
        let(:retailer_user_agent) { create(:retailer_user, :with_retailer, :agent, retailer: retailer) }
        let!(:agent_customer1) { create(:agent_customer, retailer_user: retailer_user, customer: customer1) }
        let!(:agent_customer2) { create(:agent_customer, retailer_user: retailer_user_agent, customer: customer2) }

        let(:mobile_token) { create(:mobile_token, retailer_user: retailer_user_agent) }

        let(:header_email) { retailer_user_agent.email }
        let(:header_device) { mobile_token.device }
        let(:header_token) { mobile_token.generate! }

        it 'returns only the customers assigned to it or those not assigned' do
          get api_v1_karix_customers_path, headers: { 'email': header_email, 'device': header_device, 'token': header_token }
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
          get api_v1_karix_customers_path, headers: { 'email': header_email, 'device': header_device, 'token': header_token }
          body = JSON.parse(response.body)

          expect(response.code).to eq('404')
          expect(body['message']).to eq('Customers not found')
        end
      end

      context 'when the tag filter is present' do
        context 'when the tag filter is "all"' do
          let!(:tag) { create(:tag, retailer: retailer) }
          let!(:customer_tag) { create(:customer_tag, tag: tag, customer: customer1) }

          it 'responses the customers with (any tag assigned/without tags assigned)' do
            get api_v1_karix_customers_path,
                params: { tag: 'all' },
                headers: { 'email': header_email, 'device': header_device, 'token': header_token }

            body = JSON.parse(response.body)

            expect(response).to have_http_status(:ok)
            expect(body['customers'].count).to eq(2)
          end
        end

        context 'when the tag filter is not "all"' do
          let(:tag) { create(:tag, retailer: retailer) }
          let!(:customer_tag) { create(:customer_tag, tag: tag, customer: customer1) }

          it 'responses only the customers with the tag assigned' do
            get api_v1_karix_customers_path,
                params: { tag: tag.id },
                headers: { 'email': header_email, 'device': header_device, 'token': header_token }

            body = JSON.parse(response.body)

            expect(response).to have_http_status(:ok)
            expect(body['customers'].count).to eq(1)
          end
        end
      end
    end
  end

  describe 'POST #create' do
    context 'when local request' do
      context 'when Gupshup integrated' do
        before do
          sign_out retailer_user
          sign_in retailer_user_gupshup
        end

        let(:message) { create(:gupshup_whatsapp_message, customer: customer3) }
        let(:service_instance) { Whatsapp::Gupshup::V1::Outbound::Msg.new }

        context 'when the message is submitted' do
          it 'will response a 200 status code and store a new gupshup whatsapp message' do
            allow_any_instance_of(Whatsapp::Gupshup::V1::Outbound::Msg).to receive(:send_message)
              .and_return(message)
            allow(Whatsapp::Gupshup::V1::Outbound::Msg).to receive(:new).and_return(service_instance)

            post '/api/v1/karix_send_whatsapp_message',
              params: {
                customer_id: customer3.id,
                message: 'New whatsapp message'
              }

            body = JSON.parse(response.body)
            expect(response.code).to eq('200')
            expect(body['message']).to eq('Notificación enviada')
          end
        end
      end

      context 'when Karix integrated' do
        let(:message) { create(:karix_whatsapp_message) }

        context 'when the message is sent without errors' do
          it 'successfully, will response a 200 status' do
            allow_any_instance_of(Whatsapp::Karix::Messages).to receive(:send_message).and_return(karix_successful_response)
            allow_any_instance_of(Whatsapp::Karix::Messages).to receive(:assign_message).and_return(message)

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
            allow_any_instance_of(Whatsapp::Karix::Messages).to receive(:send_message).and_return({ 'error': { 'message':
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

      context 'when the retailer has an unlimited account' do
        before do
          retailer.update!(unlimited_account: true)
        end

        context 'when it is a HSM message' do
          context 'when it is not a positive balance' do
            it 'returns a 401 status' do
              retailer.update!(ws_balance: 0.0671)

              post '/api/v1/karix_send_whatsapp_message',
                  params: {
                    customer_id: customer1.id,
                    message: 'New whatsapp message',
                    template: true
                  }

              body = JSON.parse(response.body)
              expect(response.code).to eq('401')
              expect(body['message']).to eq('Usted no tiene suficiente saldo para enviar mensajes de Whatsapp, '\
                                            'por favor, contáctese con su agente de ventas para recargar su saldo')
            end
          end

          context 'when it is a positive balance' do
            let(:message) { create(:karix_whatsapp_message) }

            before do
              allow_any_instance_of(Whatsapp::Karix::Messages).to receive(:send_message)
                .and_return(karix_successful_response)
              allow_any_instance_of(Whatsapp::Karix::Messages).to receive(:assign_message).and_return(message)
            end

            it 'returns a 200 status' do
              retailer.update!(ws_balance: 1.0)

              post '/api/v1/karix_send_whatsapp_message',
                params: {
                  customer_id: customer1.id,
                  message: 'New whatsapp message',
                  template: true
                }

              body = JSON.parse(response.body)
              expect(response.code).to eq('200')
              expect(body['message']).to eq(karix_successful_response['objects'][0])
            end
          end
        end

        context 'when it is a conversation message' do
          let(:message) { create(:karix_whatsapp_message) }

          before do
            allow_any_instance_of(Whatsapp::Karix::Messages).to receive(:send_message)
              .and_return(karix_successful_response)
            allow_any_instance_of(Whatsapp::Karix::Messages).to receive(:assign_message).and_return(message)
          end

          it 'returns a 200 status' do
            retailer.update!(ws_balance: 0.0)

            post '/api/v1/karix_send_whatsapp_message',
              params: {
                customer_id: customer1.id,
                message: 'New whatsapp message',
                template: false
              }

            body = JSON.parse(response.body)
            expect(response.code).to eq('200')
            expect(body['message']).to eq(karix_successful_response['objects'][0])
          end
        end
      end
    end

    context 'when mobile request' do
      before do
        sign_out retailer_user
      end

      context 'when Gupshup integrated' do
        let(:mobile_token) { create(:mobile_token, retailer_user: retailer_user_gupshup) }

        let(:header_email) { retailer_user_gupshup.email }
        let(:header_device) { mobile_token.device }
        let(:header_token) { mobile_token.generate! }

        let(:message) { create(:gupshup_whatsapp_message, customer: customer3) }
        let(:service_instance) { Whatsapp::Gupshup::V1::Outbound::Msg.new }

        context 'when the message is submitted' do
          it 'will response a 200 status code and store a new gupshup whatsapp message' do
            allow_any_instance_of(Whatsapp::Gupshup::V1::Outbound::Msg).to receive(:send_message)
              .and_return(message)
            allow(Whatsapp::Gupshup::V1::Outbound::Msg).to receive(:new).and_return(service_instance)

            post '/api/v1/karix_send_whatsapp_message',
              params: {
                customer_id: customer3.id,
                message: 'New whatsapp message'
              },
              headers: { 'email': header_email, 'device': header_device, 'token': header_token }

            body = JSON.parse(response.body)
            expect(response.code).to eq('200')
            expect(body['message']).to eq('Notificación enviada')
          end
        end
      end

      context 'when Karix integrated' do
        let(:mobile_token) { create(:mobile_token, retailer_user: retailer_user) }

        let(:header_email) { retailer_user.email }
        let(:header_device) { mobile_token.device }
        let(:header_token) { mobile_token.generate! }

        let(:message) { create(:karix_whatsapp_message) }

        context 'when the message is sent without errors' do
          it 'successfully, will response a 200 status' do
            allow_any_instance_of(Whatsapp::Karix::Messages).to receive(:send_message).and_return(karix_successful_response)
            allow_any_instance_of(Whatsapp::Karix::Messages).to receive(:assign_message).and_return(message)

            post '/api/v1/karix_send_whatsapp_message',
                 params: {
                   customer_id: customer1.id,
                   message: 'New whatsapp message'
                 },
                 headers: { 'email': header_email, 'device': header_device, 'token': header_token }

            body = JSON.parse(response.body)
            expect(response.code).to eq('200')
            expect(body['message']).to eq(karix_successful_response['objects'][0])
          end
        end

        context 'when the message is not sent' do
          it 'fails and will response a 500 status' do
            allow_any_instance_of(Whatsapp::Karix::Messages).to receive(:send_message).and_return({ 'error': { 'message':
              'Connection rejected' }}.with_indifferent_access)

            post '/api/v1/karix_send_whatsapp_message',
                 params: {
                   customer_id: customer1.id,
                   message: 'New whatsapp message'
                 },
                 headers: { 'email': header_email, 'device': header_device, 'token': header_token }

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
                 },
                 headers: { 'email': header_email, 'device': header_device, 'token': header_token }

            body = JSON.parse(response.body)
            expect(response.code).to eq('401')
            expect(body['message']).to eq('Usted no tiene suficiente saldo para enviar mensajes de Whatsapp, '\
                                          'por favor, contáctese con su agente de ventas para recargar su saldo')
          end
        end
      end

      context 'when the retailer has an unlimited account' do
        let(:mobile_token) { create(:mobile_token, retailer_user: retailer_user) }

        let(:header_email) { retailer_user.email }
        let(:header_device) { mobile_token.device }
        let(:header_token) { mobile_token.generate! }

        before do
          retailer.update!(unlimited_account: true)
        end

        context 'when it is a HSM message' do
          context 'when it is not a positive balance' do
            it 'returns a 401 status' do
              retailer.update!(ws_balance: 0.0671)

              post '/api/v1/karix_send_whatsapp_message',
                   params: {
                     customer_id: customer1.id,
                     message: 'New whatsapp message',
                     template: true
                   },
                   headers: { 'email': header_email, 'device': header_device, 'token': header_token }

              body = JSON.parse(response.body)
              expect(response.code).to eq('401')
              expect(body['message']).to eq('Usted no tiene suficiente saldo para enviar mensajes de Whatsapp, '\
                                            'por favor, contáctese con su agente de ventas para recargar su saldo')
            end
          end

          context 'when it is a positive balance' do
            let(:message) { create(:karix_whatsapp_message) }

            before do
              allow_any_instance_of(Whatsapp::Karix::Messages).to receive(:send_message)
                .and_return(karix_successful_response)
              allow_any_instance_of(Whatsapp::Karix::Messages).to receive(:assign_message).and_return(message)
            end

            it 'returns a 200 status' do
              retailer.update!(ws_balance: 1.0)

              post '/api/v1/karix_send_whatsapp_message',
                   params: {
                     customer_id: customer1.id,
                     message: 'New whatsapp message',
                     template: true
                   },
                   headers: { 'email': header_email, 'device': header_device, 'token': header_token }

              body = JSON.parse(response.body)
              expect(response.code).to eq('200')
              expect(body['message']).to eq(karix_successful_response['objects'][0])
            end
          end
        end

        context 'when it is a conversation message' do
          let(:message) { create(:karix_whatsapp_message) }

          before do
            allow_any_instance_of(Whatsapp::Karix::Messages).to receive(:send_message)
              .and_return(karix_successful_response)
            allow_any_instance_of(Whatsapp::Karix::Messages).to receive(:assign_message).and_return(message)
          end

          it 'returns a 200 status' do
            retailer.update!(ws_balance: 0.0)

            post '/api/v1/karix_send_whatsapp_message',
                 params: {
                   customer_id: customer1.id,
                   message: 'New whatsapp message',
                   template: false
                 },
                 headers: { 'email': header_email, 'device': header_device, 'token': header_token }

            body = JSON.parse(response.body)
            expect(response.code).to eq('200')
            expect(body['message']).to eq(karix_successful_response['objects'][0])
          end
        end
      end
    end
  end

  describe 'GET #messages' do
    context 'when Karix integrated' do
      context 'when local request' do
        context 'when the customer selected has messages' do
          context 'when the retailer has positive balance' do
            it 'successfully response a 200 status' do
              get "/api/v1/karix_whatsapp_customers/#{customer1.id}/messages"
              body = JSON.parse(response.body)

              expect(response.code).to eq('200')
              expect(body['messages'].count).to eq(6)
            end
          end

          context 'when the retailer has an unlimited account' do
            before do
              retailer.update!(unlimited_account: true, ws_balance: 0.0)
            end

            it 'successfully response a 200 status' do
              get "/api/v1/karix_whatsapp_customers/#{customer1.id}/messages"
              body = JSON.parse(response.body)

              expect(response.code).to eq('200')
              expect(body['messages'].count).to eq(6)
            end
          end

          context 'when the retailer has not enough balance' do
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

        it 'marks as read only not failed or read inbound messages' do
          total_unread = customer1.karix_whatsapp_messages.where.not(status: ['read', 'failed']).count
          expect(total_unread).to eq(4)

          get "/api/v1/karix_whatsapp_customers/#{customer1.id}/messages"
          body = JSON.parse(response.body)

          expect(response.code).to eq('200')
          expect(body['messages'].count).to eq(6)

          total_unread = customer1.karix_whatsapp_messages.where.not(status: ['read', 'failed']).count
          expect(total_unread).to eq(2)
        end
      end

      context 'when mobile request' do
        before do
          sign_out retailer_user
        end

        let(:mobile_token) { create(:mobile_token, retailer_user: retailer_user) }

        let(:header_email) { retailer_user.email }
        let(:header_device) { mobile_token.device }
        let(:header_token) { mobile_token.generate! }

        context 'when the customer selected has messages' do
          context 'when the retailer has positive balance' do
            it 'successfully response a 200 status' do
              get "/api/v1/karix_whatsapp_customers/#{customer1.id}/messages",
                  headers: { 'email': header_email, 'device': header_device, 'token': header_token }
              body = JSON.parse(response.body)

              expect(response.code).to eq('200')
              expect(body['messages'].count).to eq(6)
            end
          end

          context 'when the retailer has an unlimited account' do
            before do
              retailer.update!(unlimited_account: true, ws_balance: 0.0)
            end

            it 'successfully response a 200 status' do
              get "/api/v1/karix_whatsapp_customers/#{customer1.id}/messages",
                  headers: { 'email': header_email, 'device': header_device, 'token': header_token }

              body = JSON.parse(response.body)

              expect(response.code).to eq('200')
              expect(body['messages'].count).to eq(6)
            end
          end

          context 'when the retailer has not enough balance' do
            it 'responses a 401 status' do
              retailer.update_attributes(ws_balance: 0.0671)

              get "/api/v1/karix_whatsapp_customers/#{customer1.id}/messages",
                  headers: { 'email': header_email, 'device': header_device, 'token': header_token }

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
            get "/api/v1/karix_whatsapp_customers/#{customer3.id}/messages",
                headers: { 'email': header_email, 'device': header_device, 'token': header_token }

            body = JSON.parse(response.body)

            expect(response.code).to eq('404')
            expect(body['message']).to eq('Messages not found')
          end
        end

        it 'marks as read only not failed or read inbound messages' do
          total_unread = customer1.karix_whatsapp_messages.where.not(status: ['read', 'failed']).count
          expect(total_unread).to eq(4)

          get "/api/v1/karix_whatsapp_customers/#{customer1.id}/messages",
            headers: { 'email': header_email, 'device': header_device, 'token': header_token }

          body = JSON.parse(response.body)

          expect(response.code).to eq('200')
          expect(body['messages'].count).to eq(6)

          total_unread = customer1.karix_whatsapp_messages.where.not(status: ['read', 'failed']).count
          expect(total_unread).to eq(2)
        end
      end
    end

    context 'when GupShup integrated' do
      before do
        create_list(:gupshup_whatsapp_message, 2, :inbound, retailer: retailer_gupshup, customer: customer3, status:
          'delivered')
        create_list(:gupshup_whatsapp_message, 2, :inbound, retailer: retailer_gupshup, customer: customer3, status:
          'read')
        create_list(:gupshup_whatsapp_message, 2, :outbound, retailer: retailer_gupshup, customer: customer3, status:
          'delivered')
        create_list(:gupshup_whatsapp_message, 2, :inbound, retailer: retailer_gupshup, customer: customer3, status:
          'error')

        sign_out retailer_user
      end

      context 'when local request' do
        before do
          sign_in retailer_user_gupshup
        end

        it 'marks as read only not failed or read inbound messages' do
          total_unread = customer3.gupshup_whatsapp_messages.where.not(status: ['read', 'error']).count
          expect(total_unread).to eq(4)

          get "/api/v1/karix_whatsapp_customers/#{customer3.id}/messages"
          body = JSON.parse(response.body)

          expect(response.code).to eq('200')
          expect(body['messages'].count).to eq(6)

          total_unread = customer3.gupshup_whatsapp_messages.where.not(status: ['read', 'error']).count
          expect(total_unread).to eq(2)
        end
      end

      context 'when mobile request' do
        before do
          sign_out retailer_user_gupshup
        end

        let(:mobile_token) { create(:mobile_token, retailer_user: retailer_user_gupshup) }

        let(:header_email) { retailer_user_gupshup.email }
        let(:header_device) { mobile_token.device }
        let(:header_token) { mobile_token.generate! }

        it 'marks as read only not failed or read inbound messages' do
          total_unread = customer3.gupshup_whatsapp_messages.where.not(status: ['read', 'error']).count
          expect(total_unread).to eq(4)

          get "/api/v1/karix_whatsapp_customers/#{customer3.id}/messages",
            headers: { 'email': header_email, 'device': header_device, 'token': header_token }

          body = JSON.parse(response.body)

          expect(response.code).to eq('200')
          expect(body['messages'].count).to eq(6)

          total_unread = customer3.gupshup_whatsapp_messages.where.not(status: ['read', 'error']).count
          expect(total_unread).to eq(2)
        end
      end
    end
  end

  describe 'POST #save_message' do
    context 'outbound message events' do
      context 'when the response from Karix does not have errors' do
        it 'successfully response a 200 status' do
          post "/api/v1/karix_whatsapp",
            params: karix_outbound_data_event

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
          karix_outbound_data_event['account_id'] = nil

          post "/api/v1/karix_whatsapp",
            params: karix_outbound_data_event

          body = JSON.parse(response.body)

          expect(response.code).to eq('404')
          expect(body['message']).to eq('Account not found')
        end
      end
    end

    context 'inbound message' do
      let(:karix_inbound_payload) do
        {
          'uid' => '50825099-97da-42ff-b74e-b6d1a725f77d',
          'type' => 'message',
          'api_version' => '2.0',
          'data' => {
            'uid' => '53de54c5-7c7a-4e39-9b20-6027ad529232',
            'account_uid' => 'f93e9db6-bfbc-4e2b-9eb7-6a501162d0cc',
            'total_cost' => '0.004',
            'refund' => 'nil',
            'source' => '+593998999999',
            'destination' => '+13253077759',
            'country' => 'US',
            'content_type' => 'text',
            'content' => {
              'text' => 'Cool'
            },
            'created_time' => '2020-05-13T13:42:53Z',
            'sent_time' => 'nil',
            'delivered_time' => 'nil',
            'updated_time' => 'nil',
            'channel' => 'whatsapp',
            'status' => 'received',
            'direction' => 'inbound',
            'error' => 'nil',
            'request_uid' => '489f73bf-91c3-4594-841b-e8e46651af96',
            'redact':false,
            'channel_details' => {
              'whatsapp' => {
                'type' => 'conversation',
                'platform_fee' => '0.004',
                'whatsapp_fee' => '0',
                'source_profile' => {
                  'name' => 'bj'
                }
              }
            },
            'api_version' => '2.0'
          },
          'account_id' => retailer.id,
          'karix_whatsapp' => {
            'uid' => '50825099-97da-42ff-b74e-b6d1a725f77d',
            'type' => 'message',
            'api_version' => '2.0',
            'data' => {
              'uid' => '53de54c5-7c7a-4e39-9b20-6027ad529232',
              'account_uid' => 'f93e9db6-bfbc-4e2b-9eb7-6a501162d0cc',
              'total_cost' => '0.004',
              'refund' => 'nil',
              'source' => '+593998999999',
              'destination' => '+13253077759',
              'country' => 'US',
              'content_type' => 'text',
              'content' => {
                'text' => 'Cool'
              },
              'created_time' => '2020-05-13T13:42:53Z',
              'sent_time' => 'nil',
              'delivered_time' => 'nil',
              'updated_time' => 'nil',
              'channel' => 'whatsapp',
              'status' => 'received',
              'direction' => 'inbound',
              'error' => 'nil',
              'request_uid' => '489f73bf-91c3-4594-841b-e8e46651af96',
              'redact':false,
              'channel_details' => {
                'whatsapp' => {
                  'type' => 'conversation',
                  'platform_fee' => '0.004',
                  'whatsapp_fee' => '0',
                  'source_profile' => {
                    'name' => 'bj'
                  }
                }
              },
              'api_version' => '2.0'
            }
          }
        }
      end

      it 'stores the customer name' do
        allow_any_instance_of(KarixWhatsappMessage).to receive(:send_push_notifications).and_return(true)

        expect {
          post '/api/v1/karix_whatsapp',
            params: karix_inbound_payload
        }.to change(Customer, :count).by(1)

        body = JSON.parse(response.body)

        expect(response.code).to eq('200')
        expect(body['message']).to eq('Succesful')
        inbound_name = karix_inbound_payload['data']['channel_details']['whatsapp']['source_profile']['name']
        expect(Customer.last.whatsapp_name).to eq(inbound_name)
      end
    end
  end

  describe 'POST #send_file' do
    context 'when local request' do
      context 'when the retailer is karix integrated' do
        let(:message) { create(:karix_whatsapp_message, customer: customer1) }

        context 'when the message is sent without errors' do
          it 'successfully, will response a 200 status' do
            allow_any_instance_of(Whatsapp::Karix::Messages).to receive(:send_message)
              .and_return(karix_successful_response)
            allow_any_instance_of(Whatsapp::Karix::Messages).to receive(:assign_message).and_return(message)

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
            allow_any_instance_of(Whatsapp::Karix::Messages).to receive(:send_message).and_return({ 'error': { 'message':
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

      context 'when the retailer is gupshup integrated' do
        before do
          sign_out retailer_user
          sign_in retailer_user_gupshup
        end

        let(:message) { create(:gupshup_whatsapp_message, customer: customer3) }
        let(:service_instance) { Whatsapp::Gupshup::V1::Outbound::Msg.new }

        context 'when the message is sent without errors' do
          it 'successfully, will response a 200 status' do
            allow_any_instance_of(Whatsapp::Gupshup::V1::Outbound::Msg).to receive(:send_message)
              .and_return(message)
            allow(Whatsapp::Gupshup::V1::Outbound::Msg).to receive(:new).and_return(service_instance)

            post "/api/v1/karix_whatsapp_send_file/#{customer3.id}",
              params: {
                file_data: fixture_file_upload(Rails.root + 'spec/fixtures/profile.jpg', 'image/jpeg')
              }

            body = JSON.parse(response.body)
            expect(response.code).to eq('200')
            expect(body['message']).to eq('Notificación enviada')
          end
        end
      end
    end

    context 'when mobile request' do
      before do
        sign_out retailer_user
      end

      let(:mobile_token) { create(:mobile_token, retailer_user: retailer_user) }

      let(:header_email) { retailer_user.email }
      let(:header_device) { mobile_token.device }
      let(:header_token) { mobile_token.generate! }

      context 'when the retailer is karix integrated' do
        let(:message) { create(:karix_whatsapp_message, customer: customer1) }

        context 'when the message is sent without errors' do
          it 'successfully, will response a 200 status' do
            allow_any_instance_of(Whatsapp::Karix::Messages).to receive(:send_message)
              .and_return(karix_successful_response)
            allow_any_instance_of(Whatsapp::Karix::Messages).to receive(:assign_message).and_return(message)

            post "/api/v1/karix_whatsapp_send_file/#{customer1.id}",
                 params: {
                   file_data: fixture_file_upload(Rails.root + 'spec/fixtures/profile.jpg', 'image/jpeg')
                 },
                 headers: { 'email': header_email, 'device': header_device, 'token': header_token }

            body = JSON.parse(response.body)
            expect(response.code).to eq('200')
            expect(body['message']).to eq(karix_successful_response['objects'][0])
          end
        end

        context 'when the message is not sent' do
          it 'fails, will response a 500 status' do
            allow_any_instance_of(Whatsapp::Karix::Messages).to receive(:send_message).and_return({ 'error': { 'message':
              'Connection rejected' }}.with_indifferent_access)

            post "/api/v1/karix_whatsapp_send_file/#{customer1.id}",
                 params: {
                   file_data: fixture_file_upload(Rails.root + 'spec/fixtures/profile.jpg', 'image/jpeg')
                 },
                 headers: { 'email': header_email, 'device': header_device, 'token': header_token }

            body = JSON.parse(response.body)
            expect(response.code).to eq('500')
            expect(body['message']).to eq('Connection rejected')
          end
        end
      end

      context 'when the retailer is gupshup integrated' do
        let(:mobile_token) { create(:mobile_token, retailer_user: retailer_user_gupshup) }

        let(:header_email) { retailer_user_gupshup.email }
        let(:header_device) { mobile_token.device }
        let(:header_token) { mobile_token.generate! }

        let(:message) { create(:gupshup_whatsapp_message, customer: customer3) }
        let(:service_instance) { Whatsapp::Gupshup::V1::Outbound::Msg.new }

        context 'when the message is sent without errors' do
          it 'successfully, will response a 200 status' do
            allow_any_instance_of(Whatsapp::Gupshup::V1::Outbound::Msg).to receive(:send_message)
              .and_return(message)
            allow(Whatsapp::Gupshup::V1::Outbound::Msg).to receive(:new).and_return(service_instance)

            post "/api/v1/karix_whatsapp_send_file/#{customer3.id}",
                 params: {
                   file_data: fixture_file_upload(Rails.root + 'spec/fixtures/profile.jpg', 'image/jpeg')
                 },
                 headers: { 'email': header_email, 'device': header_device, 'token': header_token }

            body = JSON.parse(response.body)
            expect(response.code).to eq('200')
            expect(body['message']).to eq('Notificación enviada')
          end
        end
      end
    end
  end

  describe 'PUT #message_read' do
    context 'when local request' do
      context 'when is karix integrated' do
        let(:message) { create(:karix_whatsapp_message, customer: customer1, status: 'delivered') }

        context 'when the message is updated without errors' do
          it 'successfully, will response a 200 status' do
            put "/api/v1/whatsapp_update_message_read/#{customer1.id}",
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

            put "/api/v1/whatsapp_update_message_read/#{customer1.id}",
              params: {
                message_id: message.id
              }

            body = JSON.parse(response.body)
            expect(response.code).to eq('500')
            expect(body['message']).to eq('Error al actualizar mensajes')
          end
        end
      end

      context 'when is gupshup integrated' do
        before do
          sign_out retailer_user
          sign_in retailer_user_gupshup
        end

        let(:message) { create(:gupshup_whatsapp_message, customer: customer3) }
        let(:service_instance) { Whatsapp::Gupshup::V1::Outbound::Msg.new }

        context 'when the message is sent without errors' do
          it 'successfully, will response a 200 status' do
            allow_any_instance_of(Whatsapp::Gupshup::V1::Outbound::Msg).to receive(:send_message)
              .and_return(message)
            allow(Whatsapp::Gupshup::V1::Outbound::Msg).to receive(:new).and_return(service_instance)

            put "/api/v1/whatsapp_update_message_read/#{customer3.id}",
              params: {
                message_id: message.id
              }

            body = JSON.parse(response.body)
            expect(response.code).to eq('200')
            expect(body['message']['id']).to eq(message.id)
          end
        end
      end
    end

    context 'when mobile request' do
      before do
        sign_out retailer_user
      end
      let(:message) { create(:karix_whatsapp_message, customer: customer1) }
      let(:mobile_token) { create(:mobile_token, retailer_user: retailer_user) }

      let(:header_email) { retailer_user.email }
      let(:header_device) { mobile_token.device }
      let(:header_token) { mobile_token.generate! }

      context 'when the message is updated without errors' do
        it 'successfully, will response a 200 status' do
          put "/api/v1/whatsapp_update_message_read/#{customer1.id}",
              params: {
                message_id: message.id
              },
              headers: { 'email': header_email, 'device': header_device, 'token': header_token }

          body = JSON.parse(response.body)
          expect(response.code).to eq('200')
          expect(body['message']['status']).to eq('read')
        end
      end

      context 'when the message is not updated because of errors' do
        it 'will response a 500 status' do
          allow_any_instance_of(KarixWhatsappMessage).to receive(:update_column).and_return(false)

          put "/api/v1/whatsapp_update_message_read/#{customer1.id}",
              params: {
                message_id: message.id
              },
              headers: { 'email': header_email, 'device': header_device, 'token': header_token }

          body = JSON.parse(response.body)
          expect(response.code).to eq('500')
          expect(body['message']).to eq('Error al actualizar mensajes')
        end
      end
    end
  end

  describe 'GET #fast_answers_for_whatsapp' do
    let(:another_retailer_user) { create(:retailer_user, :agent, retailer: retailer) }
    let(:retailer_user_agent) { create(:retailer_user, :agent, retailer: retailer) }

    context 'when local request' do
      before do
        sign_out retailer_user
        sign_in retailer_user_agent
      end

      context 'when the templates are global' do
        before do
          create_list(:template, 3, :for_whatsapp, :global_template, retailer: retailer, retailer_user: retailer_user)
          create_list(:template, 3, :for_whatsapp, :global_template, retailer: retailer, retailer_user:
            another_retailer_user)
        end

        it 'returns a whatsapp fast answers list to all agents' do
          get api_v1_fast_answers_for_whatsapp_path
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(body['templates']['data'].count).to eq(6)
        end
      end

      context 'when the templates do not have retailer user associated' do
        before do
          create_list(:template, 3, :for_whatsapp, retailer: retailer)
        end

        it 'returns a whatsapp fast answers list to all agents' do
          get api_v1_fast_answers_for_whatsapp_path
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(body['templates']['data'].count).to eq(3)
        end
      end

      context 'when search param is present' do
        before do
          create(:template, :for_whatsapp, retailer: retailer, title: 'Texto de prueba', answer: 'Anything')
          create(:template, :for_whatsapp, retailer: retailer, title: 'Anything', answer: 'Contenido de prueba')
          create(:template, :for_messenger, retailer: retailer, title: 'Texto de prueba', answer: 'Anything')
          create(:template, :for_messenger, retailer: retailer, title: 'Anything', answer: 'Contenido de prueba')
        end

        it 'filters by title' do
          get api_v1_fast_answers_for_whatsapp_path, params: { search: 'texto' }
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(body['templates']['data'].count).to eq(1)
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

      context 'when the templates are not global and they have retailer user associated' do
        context 'when it is not the templates creator' do
          before do
            create_list(:template, 3, :for_whatsapp, retailer: retailer, retailer_user:
              another_retailer_user)
            create_list(:template, 4, :for_whatsapp, retailer: retailer, retailer_user: retailer_user)
          end

          it 'does not return any template' do
            get api_v1_fast_answers_for_whatsapp_path
            body = JSON.parse(response.body)

            expect(response).to have_http_status(:ok)
            expect(body['templates']['data'].count).to eq(0)
          end
        end

        context 'when it is the templates creator' do
          before do
            create_list(:template, 3, :for_whatsapp, retailer: retailer, retailer_user:
              another_retailer_user)
            create_list(:template, 4, :for_whatsapp, retailer: retailer, retailer_user: retailer_user_agent)
          end

          it 'returns the templates belonging to it' do
            get api_v1_fast_answers_for_whatsapp_path
            body = JSON.parse(response.body)

            expect(response).to have_http_status(:ok)
            expect(body['templates']['data'].count).to eq(4)
          end
        end
      end
    end

    context 'when mobile request' do
      let(:mobile_token) { create(:mobile_token, retailer_user: retailer_user_agent) }

      let(:header_email) { retailer_user_agent.email }
      let(:header_device) { mobile_token.device }
      let(:header_token) { mobile_token.generate! }

      before do
        sign_out retailer_user
      end

      context 'when the templates are global' do
        before do
          create_list(:template, 3, :for_whatsapp, :global_template, retailer: retailer, retailer_user: retailer_user)
          create_list(:template, 3, :for_whatsapp, :global_template, retailer: retailer, retailer_user:
            another_retailer_user)
        end

        it 'returns a whatsapp fast answers list to all agents' do
          get api_v1_fast_answers_for_whatsapp_path, headers: {
            'email': header_email,
            'device': header_device,
            'token': header_token
          }
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(body['templates']['data'].count).to eq(6)
        end
      end

      context 'when the templates do not have retailer user associated' do
        before do
          create_list(:template, 3, :for_whatsapp, retailer: retailer)
        end

        it 'returns a whatsapp fast answers list to all agents' do
          get api_v1_fast_answers_for_whatsapp_path, headers: {
            'email': header_email,
            'device': header_device,
            'token': header_token
          }
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(body['templates']['data'].count).to eq(3)
        end
      end

      context 'when search param is present' do
        before do
          create(:template, :for_whatsapp, retailer: retailer, title: 'Texto de prueba', answer: 'Anything')
          create(:template, :for_whatsapp, retailer: retailer, title: 'Anything', answer: 'Contenido de prueba')
          create(:template, :for_messenger, retailer: retailer, title: 'Texto de prueba', answer: 'Anything')
          create(:template, :for_messenger, retailer: retailer, title: 'Anything', answer: 'Contenido de prueba')
        end

        it 'filters by title' do
          get api_v1_fast_answers_for_whatsapp_path,
              params: { search: 'texto' },
              headers: { 'email': header_email, 'device': header_device, 'token': header_token }

          body = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(body['templates']['data'].count).to eq(1)
          expect(body['templates']['data'][0]['attributes']['title']).to include('Texto')
        end

        it 'filters by content' do
          get api_v1_fast_answers_for_whatsapp_path,
              params: { search: 'contenido' },
              headers: { 'email': header_email, 'device': header_device, 'token': header_token }

          body = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(body['templates']['data'].count).to eq(1)
          expect(body['templates']['data'][0]['attributes']['answer']).to include('Contenido')
        end
      end

      context 'when the templates are not global and they have retailer user associated' do
        context 'when it is not the templates creator' do
          before do
            create_list(:template, 3, :for_whatsapp, retailer: retailer, retailer_user:
              another_retailer_user)
            create_list(:template, 4, :for_whatsapp, retailer: retailer, retailer_user: retailer_user)
          end

          it 'does not return any template' do
            get api_v1_fast_answers_for_whatsapp_path, headers: {
              'email': header_email,
              'device': header_device,
              'token': header_token
            }
            body = JSON.parse(response.body)

            expect(response).to have_http_status(:ok)
            expect(body['templates']['data'].count).to eq(0)
          end
        end

        context 'when it is the templates creator' do
          before do
            create_list(:template, 3, :for_whatsapp, retailer: retailer, retailer_user:
              another_retailer_user)
            create_list(:template, 4, :for_whatsapp, retailer: retailer, retailer_user: retailer_user_agent)
          end

          it 'returns the templates belonging to it' do
            get api_v1_fast_answers_for_whatsapp_path, headers: {
              'email': header_email,
              'device': header_device,
              'token': header_token
            }
            body = JSON.parse(response.body)

            expect(response).to have_http_status(:ok)
            expect(body['templates']['data'].count).to eq(4)
          end
        end
      end
    end
  end

  describe 'PUT #set_chat_as_unread' do
    describe 'when chat service is facebook' do
      before do
        allow(FacebookNotificationHelper).to receive(:broadcast_data).and_return(true)
      end

      it 'sets the chat as unread' do
        patch "/api/v1/whatsapp_unread_chat/#{customer1.id}",
          params: {
            chat_service: 'facebook'
          }

        expect(response.code).to eq('200')
        expect(customer1.reload.unread_messenger_chat).to eq(true)
      end

      context 'when the retailer user is an agent' do
        let(:retailer_user_agent) { create(:retailer_user, :with_retailer, :agent, retailer: retailer) }
        let!(:agent_customer1) { create(:agent_customer, retailer_user: retailer_user, customer: customer1) }

        before do
          sign_out retailer_user
          sign_in retailer_user_agent
        end

        it 'sets the chat as unread when customer.agent is present' do
          patch "/api/v1/whatsapp_unread_chat/#{customer1.id}",
            params: {
              chat_service: 'facebook'
            }

          expect(response.code).to eq('200')
          expect(assigns(:customer)).to be_present
          expect(customer1.reload.unread_messenger_chat).to eq(true)
        end
      end
    end

    describe 'when chat service is whatsapp' do
      context 'when local request' do
        describe 'when the retailer is karix integrated' do
          before do
            allow(KarixNotificationHelper).to receive(:broadcast_data).and_return(true)
          end

          it 'sets the chat as unread' do
            patch "/api/v1/whatsapp_unread_chat/#{customer2.id}",
              params: {
                chat_service: 'whatsapp'
              }

            expect(response.code).to eq('200')
            expect(customer2.reload.unread_whatsapp_chat).to eq(true)
          end
        end

        describe 'when the retailer is gupshup integrated' do
          before do
            allow_any_instance_of(Whatsapp::Gupshup::V1::Helpers::Messages).to receive(:notify_new_counter).and_return(true)

            sign_out retailer_user
            sign_in retailer_user_gupshup
          end

          it 'sets the chat as unread' do
            patch "/api/v1/whatsapp_unread_chat/#{customer3.id}",
              params: {
                chat_service: 'whatsapp'
              }

            expect(response.code).to eq('200')
            expect(customer3.reload.unread_whatsapp_chat).to eq(true)
          end
        end
      end

      context 'when mobile request' do
        before do
          sign_out retailer_user
        end

        let(:mobile_token) { create(:mobile_token, retailer_user: retailer_user) }

        let(:header_email) { retailer_user.email }
        let(:header_device) { mobile_token.device }
        let(:header_token) { mobile_token.generate! }

        describe 'when the retailer is karix integrated' do
          before do
            allow(KarixNotificationHelper).to receive(:broadcast_data).and_return(true)
          end

          it 'sets the chat as unread' do
            patch "/api/v1/whatsapp_unread_chat/#{customer2.id}",
                  params: {
                    chat_service: 'whatsapp'
                  },
                  headers: { 'email': header_email, 'device': header_device, 'token': header_token }

            expect(response.code).to eq('200')
            expect(customer2.reload.unread_whatsapp_chat).to eq(true)
          end
        end

        describe 'when the retailer is gupshup integrated' do
          before do
            allow_any_instance_of(Whatsapp::Gupshup::V1::Helpers::Messages).to receive(:notify_new_counter).and_return(true)
          end

          it 'sets the chat as unread' do
            patch "/api/v1/whatsapp_unread_chat/#{customer3.id}",
                  params: {
                    chat_service: 'whatsapp'
                  },
                  headers: { 'email': header_email, 'device': header_device, 'token': header_token }

            expect(response.code).to eq('200')
            expect(customer3.reload.unread_whatsapp_chat).to eq(true)
          end
        end
      end
    end
  end

  describe 'POST #send_bulk_files' do
    let(:ok_net_response) { Net::HTTPOK.new(1.0, '200', 'OK') }
    let(:ok_body_response) do
      {
        status: 'submitted',
        messageId: 'ee4a68a0-1203-4c85-8dc3-49d0b3226a35'
      }.to_json
    end

    context 'when mobile request' do
      context 'when the retailer is gupshup integrated' do
        let(:header_email) { retailer_user_gupshup.email }
        let(:mobile_token) { create(:mobile_token, retailer_user: retailer_user_gupshup) }
        let(:header_device) { mobile_token.device }
        let(:header_token) { mobile_token.generate! }

        context 'when the message is sent without errors' do
          it 'successfully, will response a 200 status' do
            allow_any_instance_of(Whatsapp::Gupshup::V1::Base).to receive(:post).and_return(ok_net_response)
            allow_any_instance_of(Net::HTTPOK).to receive(:read_body).and_return(ok_body_response)
            post "/api/v1/karix_whatsapp_send_bulk_files/#{customer3.id}",
              params: {
                url: 'https://res.cloudinary.com/hs5vmn5xd/image/upload/v1601084668/fgloe3nljoxidzmcou6v.jpg',
                template: false,
                id: customer3.id
              },
              headers: { email: header_email, device: header_device, token: header_token }

            body = JSON.parse(response.body)
            expect(response.code).to eq('200')
            expect(body["message"]).to eq('Notificación enviada')
          end
        end

        context 'when params are missing' do
          it 'returns error when url is not sent' do
            post "/api/v1/karix_whatsapp_send_bulk_files/#{customer3.id}",
              params: {
                template: false,
                id: customer3.id
              },
              headers: { email: header_email, device: header_device, token: header_token }

            body = JSON.parse(response.body)
            expect(response.code).to eq("400")
            expect(body['message']).to eq("Faltaron parámetros")
          end
        end
      end
    end

    context 'when local request' do
      let(:cloudinary_image_response) do
        {
          'public_id': 'udbdbn7nv4xxupagiaxc',
          'version': 1585073676,
          'signature': '5d01c78a3b9e3ecd7563ce0cfd72bb48a256ee64',
          'width': 236,
          'height': 203,
          'format': 'jpeg',
          'resource_type': 'image',
          'created_at': '2020-03-24T18:14:36Z',
          'tags': [],
          'bytes': 17804,
          'type': 'upload',
          'etag': 'ae455f6806cb00961ca947e120277fb3',
          'placeholder': false,
          'url': 'http://res.cloudinary.com/dhhrdm74a/image/upload/v1585073676/udbdbn7nv4xxupagiaxc.jpg',
          'secure_url': 'https://res.cloudinary.com/dhhrdm74a/image/upload/v1585073676/udbdbn7nv4xxupagiaxc.jpg',
          'original_filename': 'test_image'
        }.with_indifferent_access
      end
      context 'when the retailer is gupshup integrated' do
        before do
          sign_in retailer_user_gupshup
        end
        context 'when the message is sent without errors' do
          it 'successfully, will response a 200 status' do
            allow_any_instance_of(Whatsapp::Gupshup::V1::Base).to receive(:post).and_return(ok_net_response)
            allow_any_instance_of(Net::HTTPOK).to receive(:read_body).and_return(ok_body_response)
            allow(Cloudinary::Uploader).to receive(:upload).and_return(cloudinary_image_response)
            post "/api/v1/karix_whatsapp_send_bulk_files/#{customer3.id}",
              params: {
                file_data: [fixture_file_upload(Rails.root + 'spec/fixtures/profile.jpg', 'image/jpeg')],
                template: false,
                id: customer3.id
              }
            body = JSON.parse(response.body)
            expect(response.code).to eq('200')
            expect(body['message']).to eq('Notificación enviada')
          end
        end
      end

      context 'when the retailer is karix integrated' do
        context 'when the message is sent without errors' do
          it 'will response a 200 status' do
            allow_any_instance_of(Whatsapp::Karix::Messages).to receive(:send_bulk_files).and_return(true)
            post "/api/v1/karix_whatsapp_send_bulk_files/#{customer3.id}",
              params: {
                file_data: [fixture_file_upload(Rails.root + 'spec/fixtures/profile.jpg', 'image/jpeg')],
                template: false,
                id: customer3.id
              }
            body = JSON.parse(response.body)
            expect(response.code).to eq('200')
            expect(body['message']).to eq('Notificación enviada')
          end
        end
      end
    end
  end
end
