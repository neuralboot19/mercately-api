require 'rails_helper'

RSpec.describe 'Retailers::Api::V1::Welcome', type: :request do
  describe 'GET #ping' do
    let(:retailer_user) { create(:retailer_user, :with_retailer, email: 'retailer@example.com') }

    it 'responses successfully if credentials are correct' do
      # Generating credentials for the retailer
      slug = retailer_user.retailer.slug
      api_key = retailer_user.retailer.generate_api_key

      # Making the request
      get '/retailers/api/v1/ping', headers: { 'Slug': slug, 'Api-Key': api_key }
      expect(response.code).to eq('200')

      # Once the response is 200 the message should be 'Ok'
      body = JSON.parse(response.body)
      expect(body['message']).to eq('Ok')
    end

    it 'responses an unauthorized response if credentials are NOT correct' do
      # Generating credentials for the retailer
      slug = retailer_user.retailer.slug
      retailer_user.retailer.generate_api_key

      # Making the request
      get '/retailers/api/v1/ping', headers: { 'Slug': slug, 'Api-Key': 'WRONGAPIKEY' }
      expect(response.code).to eq('401')

      # Once the response is 200 the message should be 'Ok'
      body = JSON.parse(response.body)
      expect(body['message']).to eq('Unauthorized')
    end

    it 'responses a Not Found response if slug NOT exists' do
      # Generating credentials for the retailer
      api_key = retailer_user.retailer.generate_api_key

      # Making the request
      get '/retailers/api/v1/ping', headers: { 'Slug': 'wrong_slug', 'Api-Key': api_key }
      expect(response.code).to eq('404')

      # Once the response is 200 the message should be 'Ok'
      body = JSON.parse(response.body)
      expect(body['message']).to eq('Resource not found')
    end
  end
end
