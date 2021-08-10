require 'rails_helper'

RSpec.describe 'Api::V1::Sessions', type: :request do
  let(:mobile_token) { create(:mobile_token) }

  describe 'POST /sign_in' do
    it 'will return a 200 response with the proper objects if sucessfully created the session' do
      retailer_user = create(:retailer_user, :with_retailer, password: 'test1234', password_confirmation: 'test1234')
      email = retailer_user.email
      password = 'test1234'

      post '/api/v1/sign_in', params: {
        retailer_user: {
          'email': email,
          'password': password,
          'mobile_push_token': 'mYM081L3pu5h7ok3n'
        }
      }

      expect(response.code).to eq('200')

      expected_response = JSON.parse(Api::V1::RetailerUserSerializer.new(
        retailer_user.reload,
        {
          include: [
            :retailer
          ]
        }
      ).serialized_json)

      body = JSON.parse(response.body)
      expect(body).to eq(expected_response)
    end
  end

  describe 'DELETE /log_out' do
    it 'will return a 200 response if sucessfully closed the session' do
      retailer_user = mobile_token.retailer_user
      retailer_user.generate_api_token!
      email = retailer_user.email
      device = retailer_user.api_session_device
      token = retailer_user.api_session_token

      delete '/api/v1/log_out', headers: { 'email': email, 'device': device, 'token': token }

      expect(response.code).to eq('200')

      body = JSON.parse(response.body)
      expect(body['message']).to eq('Sesión cerrada correctamente')
    end
  end
end
