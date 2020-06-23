require 'rails_helper'

RSpec.describe 'Api::V1::ProductsController', type: :request do
  let(:retailer) { create(:retailer) }
  let!(:retailer_user) { create(:retailer_user, retailer: retailer) }
  let!(:product1) { create(:product, retailer: retailer, title: 'Example of filter by title') }
  let!(:product2) { create(:product, retailer: retailer, description: 'Example of filter by description') }

  before do
    sign_in retailer_user
  end

  describe 'GET #index' do
    it 'filters by title' do
      get api_v1_products_path, params: { search: 'filter by title' }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body['products']['data'].count).to eq(1)
    end

    it 'filters by description' do
      get api_v1_products_path, params: { search: 'filter by description' }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body['products']['data'].count).to eq(1)
    end

    context 'when the retailer has products' do
      it 'responses ok' do
        get api_v1_products_path
        body = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(body['products']['data'].count).to eq(2)
      end
    end

    context 'when the retailer does not have products' do
      let(:another_retailer) { create(:retailer) }
      let(:another_retailer_user) { create(:retailer_user, retailer: another_retailer) }

      before do
        sign_out retailer_user
        sign_in another_retailer_user
      end

      it 'responses not_found' do
        get api_v1_products_path
        body = JSON.parse(response.body)

        expect(response).to have_http_status(:not_found)
        expect(body['products']['data'].count).to eq(0)
      end
    end
  end
end
