require 'rails_helper'

RSpec.describe 'Api::V1::AgentCustomersController', type: :request do
  let(:retailer_user) { create(:retailer_user, :admin, retailer: customer.retailer) }
  let(:retailer_user_agent) { create(:retailer_user, :agent, retailer: customer.retailer) }

  before do
    sign_in retailer_user
  end

  describe 'PUT #update' do
    describe 'when chat service is NOT Facebook' do
      context 'when local request' do
        describe 'when karix_integrated' do
          let(:customer) { create(:customer, :with_retailer_karix_integrated) }
          let(:message) { create(:karix_whatsapp_message, :inbound, customer: customer, created_time: Time.now) }

          context 'when the agent customer is a new record' do
            it 'successfully, a 200 Ok will be responsed' do
              put "/api/v1/customers/#{customer.id}/assign_agent",
                params: {
                  agent: {
                    retailer_user_id: retailer_user_agent.id
                  }
                }

              expect(response.code).to eq('200')
              expect(retailer_user_agent.agent_customers.count).to eq(1)
            end
          end

          context 'when the agent customer is updated' do
            let!(:agent_customer) { create(:agent_customer, retailer_user: retailer_user_agent, customer: customer) }

            it 'successfully, a 200 Ok will be responsed' do
              put "/api/v1/customers/#{customer.id}/assign_agent",
                params: {
                  agent: {
                    retailer_user_id: retailer_user.id
                  }
                }

              expect(response.code).to eq('200')
              expect(retailer_user.agent_customers.count).to eq(1)
              expect(retailer_user_agent.agent_customers.count).to eq(0)
            end
          end

          context 'when the agent customer is destroyed' do
            let!(:agent_customer) { create(:agent_customer, retailer_user: retailer_user_agent, customer: customer) }

            it 'successfully, a 200 Ok will be responsed' do
              put "/api/v1/customers/#{customer.id}/assign_agent",
                params: {
                  agent: {
                    retailer_user_id: nil
                  }
                }

              expect(response.code).to eq('200')
              expect(retailer_user_agent.agent_customers.count).to eq(0)
            end
          end

          context 'when the agent customer can not be save' do
            it 'fails, a 500 Error will be responsed' do
              put '/api/v1/customers/nil/assign_agent',
                params: {
                  agent: {
                    retailer_user_id: retailer_user.id
                  }
                }

              expect(response.code).to eq('500')
            end
          end
        end

        describe 'when gupshup_integrated' do
          let(:customer) { create(:customer, :with_retailer_gupshup_integrated) }
          let(:message) { create(:gupshup_whatsapp_message, :inbound, customer: customer) }

          context 'when the agent customer is a new record' do
            it 'successfully, a 200 Ok will be responsed' do
              put "/api/v1/customers/#{customer.id}/assign_agent",
                params: {
                  agent: {
                    retailer_user_id: retailer_user_agent.id
                  }
                }

              expect(response.code).to eq('200')
              expect(retailer_user_agent.agent_customers.count).to eq(1)
            end
          end

          context 'when the agent customer is updated' do
            let!(:agent_customer) { create(:agent_customer, retailer_user: retailer_user_agent, customer: customer) }

            it 'successfully, a 200 Ok will be responsed' do
              put "/api/v1/customers/#{customer.id}/assign_agent",
                params: {
                  agent: {
                    retailer_user_id: retailer_user.id
                  }
                }

              expect(response.code).to eq('200')
              expect(retailer_user.agent_customers.count).to eq(1)
              expect(retailer_user_agent.agent_customers.count).to eq(0)
            end
          end

          context 'when the agent customer is destroyed' do
            let!(:agent_customer) { create(:agent_customer, retailer_user: retailer_user_agent, customer: customer) }

            it 'successfully, a 200 Ok will be responsed' do
              put "/api/v1/customers/#{customer.id}/assign_agent",
                params: {
                  agent: {
                    retailer_user_id: nil
                  }
                }

              expect(response.code).to eq('200')
              expect(retailer_user_agent.agent_customers.count).to eq(0)
            end
          end

          context 'when the agent customer can not be save' do
            it 'fails, a 500 Error will be responsed' do
              put '/api/v1/customers/nil/assign_agent',
                params: {
                  agent: {
                    retailer_user_id: retailer_user.id
                  }
                }

              expect(response.code).to eq('500')
            end
          end
        end
      end

      context 'when mobile request' do
        before do
          retailer_user.generate_api_token!
          sign_out retailer_user
        end

        let(:mobile_token) { create(:mobile_token, retailer_user: retailer_user) }

        let(:header_email) { retailer_user.email }
        let(:header_device) { retailer_user.api_session_device }
        let(:header_token) { retailer_user.api_session_token }

        describe 'when karix_integrated' do
          let(:customer) { create(:customer, :with_retailer_karix_integrated) }
          let(:message) { create(:karix_whatsapp_message, :inbound, customer: customer, created_time: Time.now) }

          context 'when the agent customer is a new record' do
            it 'successfully, a 200 Ok will be responsed' do
              put "/api/v1/customers/#{customer.id}/assign_agent",
                  params: {
                    agent: {
                      retailer_user_id: retailer_user_agent.id
                    }
                  },
                  headers: { 'email': header_email, 'device': header_device, 'token': header_token }

              expect(response.code).to eq('200')
              expect(retailer_user_agent.agent_customers.count).to eq(1)
            end
          end

          context 'when the agent customer is updated' do
            let!(:agent_customer) { create(:agent_customer, retailer_user: retailer_user_agent, customer: customer) }

            it 'successfully, a 200 Ok will be responsed' do
              put "/api/v1/customers/#{customer.id}/assign_agent",
                  params: {
                    agent: {
                      retailer_user_id: retailer_user.id
                    }
                  },
                  headers: { 'email': header_email, 'device': header_device, 'token': header_token }

              expect(response.code).to eq('200')
              expect(retailer_user.agent_customers.count).to eq(1)
              expect(retailer_user_agent.agent_customers.count).to eq(0)
            end
          end

          context 'when the agent customer is destroyed' do
            let!(:agent_customer) { create(:agent_customer, retailer_user: retailer_user_agent, customer: customer) }

            it 'successfully, a 200 Ok will be responsed' do
              put "/api/v1/customers/#{customer.id}/assign_agent",
                  params: {
                    agent: {
                      retailer_user_id: nil
                    }
                  },
                  headers: { 'email': header_email, 'device': header_device, 'token': header_token }

              expect(response.code).to eq('200')
              expect(retailer_user_agent.agent_customers.count).to eq(0)
            end
          end

          context 'when the agent customer can not be save' do
            it 'fails, a 500 Error will be responsed' do
              put '/api/v1/customers/nil/assign_agent',
                  params: {
                    agent: {
                      retailer_user_id: retailer_user.id
                    }
                  },
                  headers: { 'email': header_email, 'device': header_device, 'token': header_token }

              expect(response.code).to eq('500')
            end
          end
        end

        describe 'when gupshup_integrated' do
          let(:customer) { create(:customer, :with_retailer_gupshup_integrated) }
          let(:message) { create(:gupshup_whatsapp_message, :inbound, customer: customer) }

          let(:mobile_token) { create(:mobile_token, retailer_user: customer.retailer.retailer_users.first) }

          let(:header_email) { customer.retailer.retailer_users.first.email }
          let(:header_device) { customer.retailer.retailer_users.first.api_session_device }
          let(:header_token) { customer.retailer.retailer_users.first.api_session_token }

          before do
            customer.retailer.retailer_users.first.generate_api_token!
          end

          context 'when the agent customer is a new record' do
            it 'successfully, a 200 Ok will be responsed' do
              put "/api/v1/customers/#{customer.id}/assign_agent",
                  params: {
                    agent: {
                      retailer_user_id: retailer_user_agent.id
                    }
                  },
                  headers: { 'email': header_email, 'device': header_device, 'token': header_token }

              expect(response.code).to eq('200')
              expect(retailer_user_agent.agent_customers.count).to eq(1)
            end
          end

          context 'when the agent customer is updated' do
            let!(:agent_customer) { create(:agent_customer, retailer_user: retailer_user_agent, customer: customer) }

            it 'successfully, a 200 Ok will be responsed' do
              put "/api/v1/customers/#{customer.id}/assign_agent",
                  params: {
                    agent: {
                      retailer_user_id: retailer_user.id
                    }
                  },
                  headers: { 'email': header_email, 'device': header_device, 'token': header_token }

              expect(response.code).to eq('200')
              expect(retailer_user.agent_customers.count).to eq(1)
              expect(retailer_user_agent.agent_customers.count).to eq(0)
            end
          end

          context 'when the agent customer is destroyed' do
            let!(:agent_customer) { create(:agent_customer, retailer_user: retailer_user_agent, customer: customer) }

            it 'successfully, a 200 Ok will be responsed' do
              put "/api/v1/customers/#{customer.id}/assign_agent",
                  params: {
                    agent: {
                      retailer_user_id: nil
                    }
                  },
                  headers: { 'email': header_email, 'device': header_device, 'token': header_token }

              expect(response.code).to eq('200')
              expect(retailer_user_agent.agent_customers.count).to eq(0)
            end
          end

          context 'when the agent customer can not be save' do
            it 'fails, a 500 Error will be responsed' do
              put '/api/v1/customers/nil/assign_agent',
                  params: {
                    agent: {
                      retailer_user_id: retailer_user.id
                    }
                  },
                  headers: { 'email': header_email, 'device': header_device, 'token': header_token }

              expect(response.code).to eq('500')
            end
          end
        end
      end
    end

    describe 'when chat service is WhatsApp' do
      context 'when local request' do
        describe 'when karix_integrated' do
          let(:customer) { create(:customer, :with_retailer_karix_integrated) }
          let(:message) { create(:karix_whatsapp_message, :inbound, customer: customer, created_time: Time.now) }

          context 'when the agent customer is a new record' do
            it 'successfully, a 200 Ok will be responsed' do
              put "/api/v1/customers/#{customer.id}/assign_agent",
                  params: {
                    agent: {
                      retailer_user_id: retailer_user_agent.id,
                      chat_service: 'whatsapp'
                    }
                  }

              expect(response.code).to eq('200')
              expect(retailer_user_agent.agent_customers.count).to eq(1)
            end
          end

          context 'when the agent customer is updated' do
            let!(:agent_customer) { create(:agent_customer, retailer_user: retailer_user_agent, customer: customer) }

            it 'successfully, a 200 Ok will be responsed' do
              put "/api/v1/customers/#{customer.id}/assign_agent",
                  params: {
                    agent: {
                      retailer_user_id: retailer_user.id,
                      chat_service: 'whatsapp'
                    }
                  }

              expect(response.code).to eq('200')
              expect(retailer_user.agent_customers.count).to eq(1)
              expect(retailer_user_agent.agent_customers.count).to eq(0)
            end
          end

          context 'when the agent customer is destroyed' do
            let!(:agent_customer) { create(:agent_customer, retailer_user: retailer_user_agent, customer: customer) }

            it 'successfully, a 200 Ok will be responsed' do
              put "/api/v1/customers/#{customer.id}/assign_agent",
                  params: {
                    agent: {
                      retailer_user_id: nil,
                      chat_service: 'whatsapp'
                    }
                  }

              expect(response.code).to eq('200')
              expect(retailer_user_agent.agent_customers.count).to eq(0)
            end
          end

          context 'when the agent customer can not be save' do
            it 'fails, a 500 Error will be responsed' do
              put '/api/v1/customers/nil/assign_agent',
                  params: {
                    agent: {
                      retailer_user_id: retailer_user.id,
                      chat_service: 'whatsapp'
                    }
                  }

              expect(response.code).to eq('500')
            end
          end
        end

        describe 'when gupshup_integrated' do
          let(:customer) { create(:customer, :with_retailer_gupshup_integrated) }
          let(:message) { create(:gupshup_whatsapp_message, :inbound, customer: customer) }

          context 'when the agent customer is a new record' do
            it 'successfully, a 200 Ok will be responsed' do
              put "/api/v1/customers/#{customer.id}/assign_agent",
                  params: {
                    agent: {
                      retailer_user_id: retailer_user_agent.id,
                      chat_service: 'whatsapp'
                    }
                  }

              expect(response.code).to eq('200')
              expect(retailer_user_agent.agent_customers.count).to eq(1)
              expect(retailer_user_agent.agent_notifications.count).to eq(1)
            end
          end

          context 'when the agent customer is updated' do
            let!(:agent_customer) { create(:agent_customer, retailer_user: retailer_user_agent, customer: customer) }

            it 'successfully, a 200 Ok will be responsed' do
              put "/api/v1/customers/#{customer.id}/assign_agent",
                  params: {
                    agent: {
                      retailer_user_id: retailer_user.id,
                      chat_service: 'whatsapp'
                    }
                  }

              expect(response.code).to eq('200')
              expect(retailer_user.agent_customers.count).to eq(1)
              expect(retailer_user_agent.agent_customers.count).to eq(0)
              expect(retailer_user.agent_notifications.count).to eq(1)
            end
          end

          context 'when the agent customer is destroyed' do
            let!(:agent_customer) { create(:agent_customer, retailer_user: retailer_user_agent, customer: customer) }

            it 'successfully, a 200 Ok will be responsed' do
              put "/api/v1/customers/#{customer.id}/assign_agent",
                  params: {
                    agent: {
                      retailer_user_id: nil,
                      chat_service: 'whatsapp'
                    }
                  }

              expect(response.code).to eq('200')
              expect(retailer_user_agent.agent_customers.count).to eq(0)
            end
          end

          context 'when the agent customer can not be save' do
            it 'fails, a 500 Error will be responsed' do
              put '/api/v1/customers/nil/assign_agent',
                  params: {
                    agent: {
                      retailer_user_id: retailer_user.id,
                      chat_service: 'whatsapp'
                    }
                  }

              expect(response.code).to eq('500')
            end
          end
        end
      end
    end

    describe 'when chat service IS Facebook' do
      let(:customer) { create(:customer, :with_retailer_gupshup_integrated) }
      let(:message) { create(:facebook_message, customer: customer) }

      before do
        allow(FacebookNotificationHelper).to receive(:broadcast_data).and_return(true)
      end

      context 'when the agent customer is a new record' do
        it 'successfully, a 200 Ok will be responsed' do
          put "/api/v1/customers/#{customer.id}/assign_agent",
            params: {
              agent: {
                retailer_user_id: retailer_user_agent.id,
                chat_service: 'facebook'
              }
            }

          expect(response.code).to eq('200')
          expect(retailer_user_agent.agent_customers.count).to eq(1)
          expect(retailer_user_agent.agent_notifications.count).to eq(1)
        end
      end

      context 'when the agent customer is updated' do
        let!(:agent_customer) { create(:agent_customer, retailer_user: retailer_user_agent, customer: customer) }

        it 'successfully, a 200 Ok will be responsed' do
          put "/api/v1/customers/#{customer.id}/assign_agent",
            params: {
              agent: {
                retailer_user_id: retailer_user.id,
                chat_service: 'facebook'
              }
            }

          expect(response.code).to eq('200')
          expect(retailer_user.agent_customers.count).to eq(1)
          expect(retailer_user_agent.agent_customers.count).to eq(0)
          expect(retailer_user.agent_notifications.count).to eq(1)
        end
      end

      context 'when the agent customer is destroyed' do
        let!(:agent_customer) { create(:agent_customer, retailer_user: retailer_user_agent, customer: customer) }

        it 'successfully, a 200 Ok will be responsed' do
          put "/api/v1/customers/#{customer.id}/assign_agent",
            params: {
              agent: {
                retailer_user_id: nil,
                chat_service: 'facebook'
              }
            }

          expect(response.code).to eq('200')
          expect(retailer_user_agent.agent_customers.count).to eq(0)
          expect(retailer_user_agent.agent_notifications.count).to eq(0)
          expect(retailer_user_agent.agent_notifications.count).to eq(0)
        end
      end

      context 'when the agent customer can not be save' do
        it 'fails, a 500 Error will be responsed' do
          put '/api/v1/customers/nil/assign_agent',
            params: {
              agent: {
                retailer_user_id: retailer_user.id,
                chat_service: 'facebook'
              }
            }

          expect(response.code).to eq('500')
        end
      end
    end
  end
end
