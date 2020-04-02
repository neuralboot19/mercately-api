require 'rails_helper'

RSpec.describe 'Api::V1::AgentCustomersController', type: :request do
  let(:retailer) { create(:retailer) }
  let(:retailer_user) { create(:retailer_user, :admin, retailer: retailer) }
  let(:retailer_user_agent) { create(:retailer_user, :agent, retailer: retailer) }

  let(:customer) { create(:customer, retailer: retailer) }

  before do
    sign_in retailer_user
  end

  describe 'PUT #update' do
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
