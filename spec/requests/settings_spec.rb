require 'rails_helper'

RSpec.describe 'Settings', type: :request do
  subject(:retailer) { create(:retailer) }
  subject(:retailer_user) { create(:retailer_user, retailer: retailer) }

  describe 'GET /retailers/:slug/api_key' do
    context 'user is not logged in' do
      it 'redirects to login page' do
        get api_key_path(retailer)
        expect(response).to redirect_to('/login')
      end
    end

    context 'user is logged in' do
      it 'shows api_key page for specific retailer' do
        sign_in retailer_user
        get api_key_path(retailer)
        expect(response).to have_http_status(:ok)
        expect(response).to render_template(:api_key)
      end
    end
  end

  describe 'POST /retailers/:slug/generate_api_key' do
    context 'user is login' do
      it 'generates a new api key' do
        sign_in retailer_user

        headers = { "ACCEPT" => "application/json" }
        post generate_api_key_path(retailer), :headers => headers

        json_response = JSON.parse(response.body)

        expect(response.content_type).to eq("application/json")
        expect(response).to have_http_status(:ok)

        expect(json_response['message']).to eq('¡API Key generada!')
        expect(json_response['info']['data']['attributes']['api_key'].size).to eq(32)
        expect(json_response['info']['data']['type']).to eq('retailer')
        expect(json_response['info']['data']['id']).to eq(retailer.id)
      end
    end
  end
end
