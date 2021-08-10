require 'rails_helper'

RSpec.describe 'Api::V1::Welcome', type: :request do
  describe 'GET #ping' do
    let(:mobile_token) { create(:mobile_token) }
    let(:retailer_user) { mobile_token.retailer_user }
    let(:email) { retailer_user.email }
    let(:device) { retailer_user.api_session_device }
    let(:token) { retailer_user.api_session_token }

    before do
      retailer_user.generate_api_token!
    end

    it 'responses successfully if credentials are correct' do
      # Making the request
      get '/api/v1/ping', headers: { 'email': email, 'device': device, 'token': token }
      expect(response.code).to eq('200')

      # Once the response is 200 the message should be 'Ok'
      body = JSON.parse(response.body)
      expect(body['message']).to eq('Ok')
    end

    it 'responses a not_found response if credentials not match' do
      # Making the request
      get '/api/v1/ping', headers: { 'email': email, 'device': 'WR0NGD3V1C3', 'token': token }
      expect(response.code).to eq('404')

      body = JSON.parse(response.body)
      expect(body['message']).to eq('Resource not found')
    end

    it 'responses an unauthorized response if token is not correct' do
      # Making the request
      get '/api/v1/ping', headers: { 'email': email, 'device': device, 'token': 'wR0n670k3N' }
      expect(response.code).to eq('401')

      body = JSON.parse(response.body)
      expect(body['message']).to eq('Unauthorized')
    end

    it 'responses a 401 response if token expired' do
      retailer_user.update(api_session_expiration: 14.days.ago)

      # Making the request
      get '/api/v1/ping', headers: { 'email': email, 'device': device, 'token': token }
      expect(response.code).to eq('401')

      # The response will return the right message
      body = JSON.parse(response.body)
      expect(body['message']).to eq('Token Expirado, se ha generado uno nuevo')

      # The response will return a new token and the record was updated
      new_token = body['info']['token']
      expect(retailer_user.reload.api_session_token).to eq(new_token)
    end

    it 'responses a forbidden response if header email not present' do
      # Making the request
      get '/api/v1/ping', headers: { 'device': 'device', 'token': 'token' }
      expect(response.code).to eq('403')

      # The response will return the right message
      body = JSON.parse(response.body)
      expect(body['message']).to eq('Forbidden')
    end

    it 'responses a forbidden response if header device not present' do
      # Making the request
      get '/api/v1/ping', headers: { 'email': 'email', 'token': 'token' }
      expect(response.code).to eq('403')

      # The response will return the right message
      body = JSON.parse(response.body)
      expect(body['message']).to eq('Forbidden')
    end

    it 'responses a unauthorized response if header token not present' do
      # Making the request
      get '/api/v1/ping', headers: { email: 'email', 'device': 'device' }
      expect(response.code).to eq('401')

      # The response will return the right message
      body = JSON.parse(response.body)
      expect(body['message']).to eq('Unauthorized')
    end
  end
end
