require 'rails_helper'

RSpec.describe Retailers::Api::V1::CustomersController, type: :request do
  include ApiDoc::V1::Customer::Api

  let!(:retailer) { create(:retailer, name: 'Test Connection') }

  let(:retailer_user) do
    create(:retailer_user, retailer: retailer, email: 'agent@example.com', first_name: 'Agent', last_name:
      'Example')
  end

  # Generating credentials for the retailer
  let(:slug) { retailer_user.retailer.slug }
  let(:api_key) { retailer_user.retailer.generate_api_key }

  describe 'PUT #update' do
    include ApiDoc::V1::Customer::Update

    let(:cus) { create(:customer, retailer: retailer, created_at: Time.now - 8.days) }

    it "updates a customer", :dox do

      put "/retailers/api/v1/customers/#{cus.id}", headers:
        {
          'Slug': slug,
          'Api-Key': api_key
        }, params: { customer: {
          first_name: 'Juan',
          last_name: 'Campos',
          email: 'juan@email.com',
          phone: '+12036534789',
          notes: 'New notes',
          address: 'Calle 5',
          city: 'Fort Worth',
          state: 'TX',
          zip_code: '76106'
        }
      }

      json_response = JSON.parse(response.body)
      expect(response.content_type).to eq "application/json"
      expect(json_response["message"]).to eq("Customer updated successfully")
    end

    context 'when an agent_id is sent' do
      it 'assigns the customer to an agent', :dox do
        expect {
          put "/retailers/api/v1/customers/#{cus.id}", headers:
            {
              'Slug': slug,
              'Api-Key': api_key
            }, params: { customer: {
              first_name: 'Juan',
              last_name: 'Campos',
              email: 'juan@email.com',
              phone: '+12036534789',
              notes: 'New notes',
              address: 'Calle 5',
              city: 'Fort Worth',
              state: 'TX',
              zip_code: '76106',
              agent_id: retailer_user.id
            }
          }
        }.to change { AgentCustomer.count }.by(1)

        json_response = JSON.parse(response.body)
        expect(response.content_type).to eq "application/json"
        expect(json_response["message"]).to eq("Customer updated successfully")
      end
    end
  end
end
