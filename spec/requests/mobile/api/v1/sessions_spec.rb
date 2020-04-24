require 'rails_helper'

RSpec.describe 'Mobile::Api::V1::Sessions', type: :request do
  let(:mobile_token) { create(:mobile_token) }

  describe 'POST /sign_in' do
    it 'will return a 200 response with the proper objects if sucessfully created the session' do
      retailer_user = create(:retailer_user, :with_retailer, password: 'test1234', password_confirmation: 'test1234')
      email = retailer_user.email
      password = 'test1234'

      expect {
        post '/mobile/api/v1/sign_in', params: { retailer_user: { 'email': email, 'password': password } }
      }.to change(MobileToken, :count).by(1)

      expect(response.code).to eq('200')

      expected_response = JSON.parse(Mobile::Api::V1::RetailerUserSerializer.new(
        retailer_user,
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
      email = mobile_token.retailer_user.email
      device = mobile_token.device
      token = mobile_token.generate!

      expect {
        delete '/mobile/api/v1/log_out', headers: { 'email': email, 'device': device, 'token': token }
      }.to change(MobileToken, :count).by(-1)

      expect(response.code).to eq('200')

      body = JSON.parse(response.body)
      expect(body['message']).to eq('Sesión cerrada correctamente')
    end
  end
end
