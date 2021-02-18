require 'rails_helper'

RSpec.describe 'Retailers::Api::V1::KarixWhatsappController', type: :request do
  include ApiDoc::V1::SendNotifications::Api

  describe 'POST #create' do
    context 'when Karix integrated' do
      let(:retailer) { create(:retailer, :karix_integrated) }
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

        context 'when the retailer has positive balance' do
          it 'successfully, a 200 Ok will be responsed' do
            # Stubbing the respose from Karix
            allow_any_instance_of(subject).to receive(:send_message).and_return(karix_successful_response)

            # Making the request
            post '/retailers/api/v1/whatsapp/send_notification',
                params: {
                  phone_number: '+5939983770633',
                  message: 'My Message Text',
                  template: false
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
        end

        context 'when the retailer has an unlimited account' do
          before do
            retailer.update!(unlimited_account: true)
          end

          context 'when is a HSM message' do
            context 'when the retailer has a positive balance' do
              it 'successfully, a 200 Ok will be responsed' do
                # Stubbing the respose from Karix
                allow_any_instance_of(subject).to receive(:send_message).and_return(karix_successful_response)

                # Making the request
                post '/retailers/api/v1/whatsapp/send_notification',
                    params: {
                      phone_number: '+5939983770633',
                      message: 'My Message Text',
                      template: true
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
            end

            context 'when the retailer does not have a positive balance' do
              it 'responses with a 401 Internal Server Error response' do
                retailer.update_attributes(ws_balance: 0.0671)

                # Making the request
                post '/retailers/api/v1/whatsapp/send_notification',
                    params: {
                      phone_number: '+5939983770633',
                      message: 'My Message Text',
                      template: true
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
            end
          end

          context 'when is a conversation message' do
            it 'successfully, a 200 Ok will be responsed' do
              # Stubbing the respose from Karix
              allow_any_instance_of(subject).to receive(:send_message).and_return(karix_successful_response)
              retailer.update_attributes(ws_balance: 0.0)

              # Making the request
              post '/retailers/api/v1/whatsapp/send_notification',
                  params: {
                    phone_number: '+5939983770633',
                    message: 'My Message Text',
                    template: false
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
          end
        end

        it 'with an error, a 500 Internal Server Error will be responsed' do
          # Stubbing the respose from Karix
          allow_any_instance_of(subject).to receive(:send_message).and_return(karix_error_response)

          # Making the request
          post '/retailers/api/v1/whatsapp/send_notification',
              params: {
                customer_id: customer.id,
                phone_number: '+5939983770633',
                message: 'My Message Text',
                template: false
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
                message: 'My Message Text',
                template: false
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
              message: 'My Message Text',
              template: false
            },
            headers: {
              'Slug': slug,
              'Api-Key': api_key
            }
        expect(response.code).to eq('500')

        body = JSON.parse(response.body)
        expect(body['message']).to eq('Error: Missing phone number and/or message and/or template')
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
        expect(body['message']).to eq('Error: Missing phone number and/or message and/or template')
      end

      it 'responses a 500 Internal Server Error response if template NOT present' do
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
        expect(body['message']).to eq('Error: Missing phone number and/or message and/or template')
      end

      it 'responses with a 401 Internal Server Error response if retailer has not enough Whatsapp balance' do
        retailer.update_attributes(ws_balance: 0.0671)

        # Making the request
        post '/retailers/api/v1/whatsapp/send_notification',
            params: {
              phone_number: '+5939983770633',
              message: 'My Message Text',
              template: false
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
              message: 'My Message Text',
              template: false
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

    context 'when GupShup integrated' do
      let(:retailer) { create(:retailer, :gupshup_integrated, ws_balance: 10) }
      let(:retailer_user) { create(:retailer_user, retailer: retailer, email: 'retailer@example.com') }
      let!(:customer) { create(:customer, retailer: retailer, phone: '+584149999999') }

      # Generating credentials for the retailer
      let(:slug) { retailer_user.retailer.slug }
      let(:api_key) { retailer_user.retailer.generate_api_key }

      let(:gupshup_successful_response) do
        {
          code: '200',
          body: {
            status: 'submitted',
            messageId: 'ee4a68a0-1203-4c85-8dc3-49d0b3226a35'
          }
        }.with_indifferent_access
      end

      let(:gupshup_error_response) do
        {
          code: '401',
          body: {
            status: 'submitted',
            messageId: 'ee4a68a0-1203-4c85-8dc3-49d0b3226a35'
          }
        }.with_indifferent_access
      end

      context 'when sending by template text' do
        context 'when customer is not opted-in' do
          let(:service_response) {
            { code: '500' }
          }

          before do
            allow_any_instance_of(Whatsapp::Gupshup::V1::Outbound::Msg).to receive(:send_message)
              .and_return(gupshup_successful_response)
            allow_any_instance_of(Whatsapp::Gupshup::V1::Outbound::Users).to receive(:opt_in)
              .and_return(service_response)
          end

          it 'responses a 500, telling the customer can not be verified' do
            # Making the request
            post '/retailers/api/v1/whatsapp/send_notification',
            params: {
              phone_number: '+584149999999',
              message: 'My Message Text',
              template: true
            },
            headers: {
              'Slug': slug,
              'Api-Key': api_key
            }

            expect(response.code).to eq('500')

            body = JSON.parse(response.body)
            expect(body['message']).to eq('Error')
            expect(body['info']['message']).to eq('No fue posible verificar el número de destino')
          end
        end

        context 'when customer is opted-in' do
          let(:service_response) {
            { code: '202' }
          }

          context 'when the message is successfully sent' do
            before do
              allow_any_instance_of(Whatsapp::Gupshup::V1::Outbound::Msg).to receive(:send_message)
                .and_return(gupshup_successful_response)
              allow_any_instance_of(Whatsapp::Gupshup::V1::Outbound::Users).to receive(:opt_in)
                .and_return(service_response)
            end

            it 'responses a 200, telling the message was submitted' do
              # Making the request
              post '/retailers/api/v1/whatsapp/send_notification',
              params: {
                phone_number: '+584149999999',
                message: 'My Message Text',
                template: true
              },
              headers: {
                'Slug': slug,
                'Api-Key': api_key
              }

              expect(response.code).to eq('200')

              body = JSON.parse(response.body)
              expect(body['message']).to eq('Ok')
              expect(body['info']['status']).to eq('submitted')
            end
          end

          context 'when the message is not sent' do
            before do
              allow_any_instance_of(Whatsapp::Gupshup::V1::Outbound::Msg).to receive(:send_message)
                .and_return(gupshup_error_response)
              allow_any_instance_of(Whatsapp::Gupshup::V1::Outbound::Users).to receive(:opt_in)
                .and_return(service_response)
            end

            it 'responses a 500, telling the message was not sent' do
              # Making the request
              post '/retailers/api/v1/whatsapp/send_notification',
              params: {
                phone_number: '+584149999999',
                message: 'My Message Text',
                template: true
              },
              headers: {
                'Slug': slug,
                'Api-Key': api_key
              }

              expect(response.code).to eq('500')

              body = JSON.parse(response.body)
              expect(body['message']).to eq('Error')
              expect(body['info']['message']).to eq('No fue posible entregar el mensaje al número de destino')
            end
          end
        end
      end
    end
  end

  describe 'POST #create_by_id' do
    include ApiDoc::V1::SendNotifications::CreateById

    context 'when GupShup integrated' do
      let(:retailer) { create(:retailer, :gupshup_integrated, ws_balance: 10, name: 'Test Connection') }
      let(:retailer_user) { create(:retailer_user, retailer: retailer, email: 'retailer@example.com') }
      let!(:customer) { create(:customer, retailer: retailer, phone: '+584149999999') }

      # Generating credentials for the retailer
      let(:slug) { retailer_user.retailer.slug }
      let(:api_key) { retailer_user.retailer.generate_api_key }

      let(:gupshup_successful_response) do
        {
          code: '200',
          body: {
            status: 'submitted',
            messageId: 'ee4a68a0-1203-4c85-8dc3-49d0b3226a35'
          }
        }.with_indifferent_access
      end

      let(:gupshup_error_response) do
        {
          code: '401',
          body: {
            status: 'submitted',
            messageId: 'ee4a68a0-1203-4c85-8dc3-49d0b3226a35'
          }
        }.with_indifferent_access
      end

      context 'when sending by template ID' do
        context 'when all the parameters are not sent' do
          it 'returns 400 - Bad Request', :dox do
            post '/retailers/api/v1/whatsapp/send_notification_by_id',
            params: {
              phone_number: '+593999999999'
            },
            headers: {
              'Slug': slug,
              'Api-Key': api_key
            }

            expect(response.code).to eq('400')

            body = JSON.parse(response.body)
            expect(body['message']).to eq('Error: Missing phone number and/or internal_id')
          end
        end

        context 'when template ID sent is not found' do
          it 'returns 404 - Not Found', :dox do
            post '/retailers/api/v1/whatsapp/send_notification_by_id',
            params: {
              phone_number: '+593999999999',
              internal_id: 'xxxxxxxxxxxxxxx'
            },
            headers: {
              'Slug': slug,
              'Api-Key': api_key
            }

            expect(response.code).to eq('404')

            body = JSON.parse(response.body)
            expect(body['message']).to eq('Error: Template not found. Please check the ID sent.')
          end
        end

        context 'when all needed template params are not sent' do
          context 'when the template has editable fields' do
            let!(:template) do
              create(:whatsapp_template, retailer: retailer, gupshup_template_id:
                '997dd550-c8d8-4bf7-ad98-a5ac4844a1ed', text: 'Your OTP for * is *. This is valid for *.')
            end

            it 'returns 400 - Bad Request', :dox do
              post '/retailers/api/v1/whatsapp/send_notification_by_id',
              params: {
                phone_number: '+593999999999',
                internal_id: '997dd550-c8d8-4bf7-ad98-a5ac4844a1ed',
                template_params: ['test 1', 'test 2']
              },
              headers: {
                'Slug': slug,
                'Api-Key': api_key
              }

              expect(response.code).to eq('400')

              body = JSON.parse(response.body)
              expect(body['message']).to eq('Error: Parameters mismatch. Required 3, but 2 sent.')
            end
          end

          context 'when the template does not have editable fields' do
            let(:service_response) { { code: '202' } }

            before do
              allow_any_instance_of(Whatsapp::Gupshup::V1::Outbound::Msg).to receive(:send_message)
                .and_return(gupshup_successful_response)
              allow_any_instance_of(Whatsapp::Gupshup::V1::Outbound::Users).to receive(:opt_in)
                .and_return(service_response)
            end

            let!(:template) do
              create(:whatsapp_template, :with_formatting_asterisks, retailer: retailer, gupshup_template_id:
                '997dd550-c8d8-4bf7-ad98-a5ac4844a1ed')
            end

            it 'responses a 200 success' do
              post '/retailers/api/v1/whatsapp/send_notification_by_id',
              params: {
                phone_number: '+584149999999',
                internal_id: '997dd550-c8d8-4bf7-ad98-a5ac4844a1ed'
              },
              headers: {
                'Slug': slug,
                'Api-Key': api_key
              }

              expect(response.code).to eq('200')

              body = JSON.parse(response.body)
              expect(body['message']).to eq('Ok')
              expect(body['info']['status']).to eq('submitted')
            end
          end
        end

        context 'when all needed template params are sent' do
          let(:service_response) { { code: '202' } }
          let!(:template) do
            create(:whatsapp_template, retailer: retailer, gupshup_template_id:
              '997dd550-c8d8-4bf7-ad98-a5ac4844a1ed', text: 'Your OTP for * is *. This is valid for *.')
          end

          before do
            allow_any_instance_of(Whatsapp::Gupshup::V1::Outbound::Msg).to receive(:send_message)
              .and_return(gupshup_successful_response)
            allow_any_instance_of(Whatsapp::Gupshup::V1::Outbound::Users).to receive(:opt_in)
              .and_return(service_response)
          end

          it 'sends the notification', :dox do
            post '/retailers/api/v1/whatsapp/send_notification_by_id',
              params: {
                phone_number: '+593999999999',
                internal_id: '997dd550-c8d8-4bf7-ad98-a5ac4844a1ed',
                template_params: ['test 1', 'test 2', 'test 3']
              },
              headers: {
                'Slug': slug,
                'Api-Key': api_key
              }

              expect(response.code).to eq('200')

              body = JSON.parse(response.body)
              expect(body['message']).to eq('Ok')
              expect(body['info']['status']).to eq('submitted')
          end

          context 'when an agent id is sent' do
            let(:agent) { create(:retailer_user, retailer: retailer) }

            it 'sends the notification, assigning the customer to the agent', :dox do
              expect {
                post '/retailers/api/v1/whatsapp/send_notification_by_id',
                  params: {
                    phone_number: '+593999999999',
                    internal_id: '997dd550-c8d8-4bf7-ad98-a5ac4844a1ed',
                    template_params: ['test 1', 'test 2', 'test 3'],
                    agent_id: agent.id
                  },
                  headers: {
                    'Slug': slug,
                    'Api-Key': api_key
                  }
                }.to change{ AgentCustomer.count }.by(1)

                expect(response.code).to eq('200')

                body = JSON.parse(response.body)
                expect(body['message']).to eq('Ok')
                expect(body['info']['status']).to eq('submitted')
            end
          end
        end
      end
    end
  end
end
