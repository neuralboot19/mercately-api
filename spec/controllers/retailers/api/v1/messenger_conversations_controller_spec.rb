require 'rails_helper'

RSpec.describe Retailers::Api::V1::MessengerConversationsController, type: :request do
  include ApiDoc::V1::MessengerConversations::Api

  let(:retailer) { create(:retailer, name: 'Test Connection') }
  let(:facebook_retailer) { create(:facebook_retailer, retailer: retailer) }
  let(:retailer_user) do
    create(:retailer_user, retailer: retailer, email: 'agent@example.com', first_name: 'Agent', last_name:
      'Example')
  end

  # Generating credentials for the retailer
  let(:slug) { retailer_user.retailer.slug }
  let(:api_key) { retailer_user.retailer.generate_api_key }

  let(:customer_1) { create(:customer, retailer: retailer, created_at: Time.now - 8.days, phone: '+593123458475') }
  let(:customer_2) { create(:customer, retailer: retailer, created_at: Time.now - 8.days, phone: '+593452365897') }
  let(:customer_3) { create(:customer, retailer: retailer, created_at: Time.now - 8.days, phone: '+593789584759') }
  let!(:agent_customer) { create(:agent_customer, retailer_user: retailer_user, customer: customer_1) }
  let!(:agent_customer_2) { create(:agent_customer, retailer_user: retailer_user, customer: customer_3) }

  describe 'GET #messenger_conversations' do
    include ApiDoc::V1::MessengerConversations::MessengerConversations

    it 'returns all messenger conversations from retailer', :dox do
      create(:facebook_message, :inbound, facebook_retailer: facebook_retailer, customer: customer_1, created_at:
        Time.now - 29.hours)
      create(:facebook_message, :inbound, facebook_retailer: facebook_retailer, customer: customer_2, created_at:
        Time.now - 25.hours)
      create(:facebook_message, :inbound, facebook_retailer: facebook_retailer, customer: customer_3, created_at:
        Time.now - 20.hours)

      get '/retailers/api/v1/messenger_conversations', headers:
        {
          'Slug': slug,
          'Api-Key': api_key
        }, params: { page: 1, results_per_page: 100 }

      expect(response).to have_http_status(:ok)
      json_response =  JSON.parse(response.body)
      expect(json_response['messenger_conversations'].count).to eq(3)
      expect(json_response.keys).to eq(['results', 'total_pages', 'messenger_conversations'])
    end

    it 'returns all unassigned messenger conversations from retailer', :dox do
      create(:facebook_message, :inbound, facebook_retailer: facebook_retailer, customer: customer_1, created_at:
        Time.now - 29.hours)
      create(:facebook_message, :inbound, facebook_retailer: facebook_retailer, customer: customer_2, created_at:
        Time.now - 25.hours)
      create(:facebook_message, :inbound, facebook_retailer: facebook_retailer, customer: customer_3, created_at:
        Time.now - 25.hours)
      create(:facebook_message, :inbound, facebook_retailer: facebook_retailer, customer:
        agent_customer.customer, created_at: Time.now - 20.hours)
      create(:facebook_message, :inbound, facebook_retailer: facebook_retailer, customer:
        agent_customer_2.customer, created_at: Time.now - 20.hours)

      get '/retailers/api/v1/messenger_conversations', headers:
        {
          'Slug': slug,
          'Api-Key': api_key
        }, params: { page: 1, results_per_page: 100, unassigned: true }

      expect(response).to have_http_status(:ok)
      json_response =  JSON.parse(response.body)
      expect(json_response['messenger_conversations'].count).to eq(1)
      expect(json_response.keys).to eq(['results', 'total_pages', 'messenger_conversations'])
    end
  end

  describe '#customer_conversations' do
    include ApiDoc::V1::MessengerConversations::CustomerConversations

    it 'returns customer Messenger conversations', :dox do
      create_list(:facebook_message, 5, :inbound, facebook_retailer: facebook_retailer, customer: customer_1, created_at:
        Time.now - 29.hours)

      get "/retailers/api/v1/customers/#{customer_1.web_id}/messenger_conversations", headers:
        {
          'Slug': slug,
          'Api-Key': api_key
        }, params: { page: 1 }

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['messenger_conversations'].count).to eq(5)
      expect(json_response.keys).to eq(['messenger_conversations', 'total_pages'])
    end

    context 'when customer does not exist' do
      it 'returns 404', :dox do
        get '/retailers/api/v1/customers/not_found/messenger_conversations', headers:
          {
            'Slug': slug,
            'Api-Key': api_key
          }, params: { page: 1 }

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
