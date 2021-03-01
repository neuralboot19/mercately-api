require 'rails_helper'

RSpec.describe Retailers::Api::V1::WhatsappConversationsController, type: :request do
  include ApiDoc::V1::WhatsappConversations::Api

  let!(:retailer) { create(:retailer, name: 'Test Connection') }

  let(:retailer_user) do
    create(:retailer_user, retailer: retailer, email: 'agent@example.com', first_name: 'Agent', last_name:
      'Example')
  end

  # Generating credentials for the retailer
  let(:slug) { retailer_user.retailer.slug }
  let(:api_key) { retailer_user.retailer.generate_api_key }

  describe 'GET #whatsapp_conversations' do
    include ApiDoc::V1::WhatsappConversations::WhatsappConversations

    let(:customer_1) { create(:customer, retailer: retailer, created_at: Time.now - 8.days, phone: '+593123458475') }
    let(:customer_2) { create(:customer, retailer: retailer, created_at: Time.now - 8.days, phone: '+593452365897') }
    let(:customer_3) { create(:customer, retailer: retailer, created_at: Time.now - 8.days, phone: '+593789584759') }
    let!(:agent_customer) { create(:agent_customer, retailer_user: retailer_user, customer: customer_1) }
    let!(:agent_customer_2) { create(:agent_customer, retailer_user: retailer_user, customer: customer_3) }

    it 'returns all whatsapp conversations from retailer', :dox do
      create(:gupshup_whatsapp_message, :inbound, retailer: retailer, customer: customer_1, created_at:
        Time.now - 29.hours)
      create(:gupshup_whatsapp_message, :inbound, retailer: retailer, customer: customer_2, created_at:
        Time.now - 25.hours)
      create(:gupshup_whatsapp_message, :inbound, retailer: retailer, customer: customer_3, created_at:
        Time.now - 20.hours)

      get '/retailers/api/v1/whatsapp_conversations', headers:
        {
          'Slug': slug,
          'Api-Key': api_key
        }, params: { page: 1, results_per_page: 100 }

      expect(response).to have_http_status(:ok)
      json_response =  JSON.parse(response.body)
      expect(json_response["whatsapp_conversations"].count).to eq(3)
      expect(json_response.keys).to eq(["results", "total_pages", "whatsapp_conversations"])
    end

    it 'returns all unassigned whatsapp conversations from retailer', :dox do
      create(:gupshup_whatsapp_message, :inbound, retailer: retailer, customer: customer_1, created_at:
        Time.now - 29.hours)
      create(:gupshup_whatsapp_message, :inbound, retailer: retailer, customer: customer_2, created_at:
        Time.now - 25.hours)
      create(:gupshup_whatsapp_message, :inbound, retailer: retailer, customer: customer_3, created_at:
        Time.now - 25.hours)
      create(:gupshup_whatsapp_message, :inbound, retailer: retailer, customer: agent_customer.customer, created_at:
        Time.now - 20.hours)
      create(:gupshup_whatsapp_message, :inbound, retailer: retailer, customer: agent_customer_2.customer, created_at:
        Time.now - 20.hours)

      get '/retailers/api/v1/whatsapp_conversations', headers:
        {
          'Slug': slug,
          'Api-Key': api_key
        }, params: { page: 1, results_per_page: 100, unassigned: true }

      expect(response).to have_http_status(:ok)
      json_response =  JSON.parse(response.body)
      expect(json_response["whatsapp_conversations"].count).to eq(1)
      expect(json_response.keys).to eq(["results", "total_pages", "whatsapp_conversations"])
    end
  end
end
