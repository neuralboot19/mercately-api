require 'rails_helper'

RSpec.describe Retailers::Api::V1::RetailerUsersController, type: :request do
  include ApiDoc::V1::RetailerUsers::Api

  describe 'GET #index' do
    include ApiDoc::V1::RetailerUsers::Index

    let(:retailer) { create(:retailer, name: 'Test Connection') }
    let(:retailer_user) do
      create(:retailer_user, retailer: retailer, email: 'agent@example.com', first_name: 'Agent', last_name:
        'Example')
    end

    # Generating credentials for the retailer
    let(:slug) { retailer_user.retailer.slug }
    let(:api_key) { retailer_user.retailer.generate_api_key }

    it 'returns a list of agents', :dox do
      get '/retailers/api/v1/agents', headers:
        {
          'Slug': slug,
          'Api-Key': api_key
        }

      expect(response).to have_http_status(:ok)
    end
  end
end
